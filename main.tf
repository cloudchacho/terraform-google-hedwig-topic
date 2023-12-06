resource "google_pubsub_topic" "topic" {
  name = "hedwig-${var.topic}"
}

resource "google_pubsub_subscription" "firehose" {
  count = var.enable_firehose_all_messages ? 1 : 0
  name  = "hedwig-${var.topic}-firehose"
  topic = "hedwig-${var.topic}"

  cloud_storage_config {
    bucket          = var.firehose_bucket
    filename_prefix = local.firehose_prefix
    max_bytes       = var.firehose_max_bytes
    max_duration    = var.firehose_max_duration
    dynamic "avro_config" {
      for_each = var.firehose_write_avro ? [1] : []
      content {
        write_metadata = true
      }
    }
  }
}


locals {
  firehose_prefix      = replace(var.firehose_prefix, "<topic>", var.topic)
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
