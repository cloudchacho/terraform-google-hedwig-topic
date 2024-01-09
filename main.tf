resource "google_pubsub_topic" "topic" {
  name = "hedwig-${var.topic}"
}

resource "google_pubsub_subscription" "firehose" {
  count = var.firehose_config != null ? 1 : 0
  name  = "hedwig-${var.topic}-firehose"
  topic = google_pubsub_topic.topic.id
  cloud_storage_config {
    bucket          = data.google_storage_bucket.firehose_bucket[0].name
    filename_prefix = var.firehose_config.filename_prefix
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
  depends_on = [
    data.google_storage_bucket.firehose_bucket[0],
    # Todo: Add explicit bucket IAM permissions dependency.
  ]
}

locals {
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

data "google_storage_bucket" "firehose_bucket" {
  count = var.firehose_config != null ? 1 : 0
  name  = var.firehose_config.bucket
}
