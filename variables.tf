variable "topic" {
  description = "Name of the Hedwig topic (should contain alphanumeric and dashes only by convention); unique across your infra"
}

variable "firehose_config" {
  description = "Variable firehose_config describes how to \"firehose\"—read as, \"save\"—Hedwig messages to Google Cloud Storage (GCS). Under the hood, firehose_config uses the cloud_storage_config google_pubsub_subscription Terraform block; for an example, see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription#example-usage---pubsub-subscription-push-cloudstorage-avro page."
  type = object({
    # Declares the bucket to firehose messages to.
    # Note: For bucket permissions, see https://cloud.google.com/pubsub/docs/create-cloudstorage-subscription#assign_roles_cloudstorage page.
    bucket = string

    # Declares the prefix for the Cloud Storage filename.
    filename_prefix = optional(string, "")

    # Declares the suffix for the Cloud Storage filename.
    filename_suffix = optional(string, "")

    # Write messages to Cloud Storage in Avro format with metadata.
    write_avro_format = optional(bool, false)

    # The maximum duration that can elapse before a new Cloud Storage file is created. Minimum is 1 minute, maximum is 10 minutes, default is 5 minutes. May not exceed the subscription's acknowledgement deadline. A duration in seconds with up to nine fractional digits, ending with 's'. Example: "3.5s".
    max_duration = optional(string, "300s")

    # The maximum bytes that can be written to a Cloud Storage file before a new file is created. Min 1 KB, max 10 GiB. The maxBytes limit may be exceeded in cases where messages are larger than the limit. Defaults to 10*1024 B = 10 MiB.
    max_bytes = optional(number, 10240)
  })
  default = null
}

variable "iam_service_accounts" {
  description = "(DEPRECATED: use members instead) The list of IAM service accounts to create exclusive IAM permissions for the topic. Flattens a list of list if necessary."
  default     = []
}

variable "iam_members" {
  description = "The list of IAM members to create exclusive IAM permissions for the topic. Flattens a list of list if necessary. The values must include appropriate IAM prefix, e.g. `group:` for google groups."
  default     = []
}
