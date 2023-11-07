resource "google_pubsub_topic" "topic" {
  name = "hedwig-${var.topic}"
}

locals {
  iam_service_accounts = formatlist("serviceAccount:%s", compact(flatten(var.iam_service_accounts)))
  iam_members = sort(toset(concat(local.iam_service_accounts, compact(flatten(var.iam_members)))))
}

data "google_iam_policy" "topic_policy" {
  dynamic "binding" {
    for_each = local.iam_members

    content {
      members = [binding.value]
      role    = "roles/pubsub.publisher"
    }
  }

  dynamic "binding" {
    for_each = local.iam_members

    content {
      members = [binding.value]
      role    = "roles/pubsub.viewer"
    }
  }
}

resource "google_pubsub_topic_iam_policy" "topic_policy" {
  policy_data = data.google_iam_policy.topic_policy.policy_data
  topic       = google_pubsub_topic.topic.name
}

data "google_client_config" "current" {
}

resource "google_dataflow_job" "firehose" {
  count = var.enable_firehose_all_messages ? 1 : 0

  name              = "${google_pubsub_topic.topic.name}-firehose"
  temp_gcs_location = var.dataflow_tmp_gcs_location
  template_gcs_path = var.dataflow_template_gcs_path

  lifecycle {
    # Google templates add their own labels so ignore changes
    ignore_changes = [labels]
  }

  zone   = var.dataflow_zone
  region = var.dataflow_region

  parameters = {
    inputTopic           = "projects/${data.google_client_config.current.project}/topics/${google_pubsub_topic.topic.name}"
    outputDirectory      = var.dataflow_output_directory
    outputFilenamePrefix = var.dataflow_output_filename_prefix == "" ? format("%s-", google_pubsub_topic.topic.name) : var.dataflow_output_filename_prefix
  }
}

data google_project current {}

locals {
  title_suffix  = var.alerting_project != data.google_project.current.project_id ? format(" (%s)", data.google_project.current.name) : ""
  filter_suffix = var.alerting_project != data.google_project.current.project_id ? format(" resource.label.\"project_id\"=\"%s\"", data.google_project.current.project_id) : ""
}

resource "google_monitoring_alert_policy" "dataflow_freshness" {
  count = var.enable_firehose_all_messages && var.enable_alerts ? 1 : 0

  project = var.alerting_project

  display_name = "${title(var.topic)} Hedwig Dataflow data freshness too stale${local.title_suffix}"
  combiner     = "OR"

  conditions {
    display_name = "Dataflow data age for ${google_dataflow_job.firehose[0].name}${local.title_suffix}"

    condition_threshold {
      threshold_value = var.dataflow_freshness_alert_threshold // Freshness is seconds
      comparison      = "COMPARISON_GT"
      duration        = "60s" // Seconds

      filter = "metric.type=\"dataflow.googleapis.com/job/data_watermark_age\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${google_dataflow_job.firehose[0].name}\"${local.filter_suffix}"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_MAX"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.dataflow_freshness_alert_notification_channels
}
