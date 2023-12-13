resource "google_pubsub_topic" "topic" {
  name = "hedwig-${var.topic}"
}

resource "google_pubsub_subscription" "firehose" {
  count = var.firehose_config.enabled ? 1 : 0
  name  = "hedwig-${var.topic}-firehose"
  topic = "hedwig-${var.topic}"
  dynamic "cloud_storage_config" {
    for_each = var.firehose_config.enabled ? [1] : []
    content {
      bucket          = var.firehose_config.bucket
      filename_prefix = local.filename_prefix
      filename_suffix = var.firehose_config.filename_suffix
      max_bytes       = var.firehose_config.max_bytes
      max_duration    = var.firehose_config.max_duration
      dynamic "avro_config" {
        for_each = var.firehose_config.write_avro_format ? [1] : []
        content {
          write_metadata = true
        }
      }
    }
  }
}

locals {
  # Gotcha: The "<topic>" string is replaced by var.topic; for example, "myenv/<topic>/" becomes "myenv/mytopic/" string. This confusing approach enables inserting var.topic into prefix in a for-loop.
  filename_prefix      = replace(var.firehose_config.filename_prefix, "<topic>", var.topic)
  iam_service_accounts = formatlist("serviceAccount:%s", compact(flatten(var.iam_service_accounts)))
  iam_members          = sort(toset(concat(local.iam_service_accounts, compact(flatten(var.iam_members)))))
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
