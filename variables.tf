variable "topic" {
  description = "Name of the Hedwig topic (should contain alphanumeric and dashes only by convention); unique across your infra"
}

variable "enable_firehose_all_messages" {
  description = "Should all messages published to this topic be firehosed—that is, saved—to Cloud Storage"
  type        = bool
  default     = false
}

variable "firehose_bucket" {
  description = "Variable firehose_bucket declares the bucket for firehose—that is, saved—messages (should already exist)"
  type        = string
  default     = ""
}

variable "firehose_prefix" {
  description = "Variable firehose_prefix declares the prefix for firehose—that is, saved—messages. Note: The \"<topic>\" string is replaced by var.topic; for example, \"myenv/<topic>/\" variable becomes \"myenv/mytopic/\" string. This confusing approach enables prefixing all topics in a for-loop."
  type        = string
  default     = ""
}

variable "dataflow_tmp_gcs_location" {
  description = "A gs bucket location for storing temporary files by Google Dataflow, e.g. gs://myBucket/tmp"
  default     = ""
}

variable "dataflow_template_gcs_path" {
  description = "The template path for Google Dataflow, e.g. gs://dataflow-templates/2019-04-24-00/Cloud_PubSub_to_GCS_Text"
  default     = ""
}

variable "dataflow_zone" {
  description = "The zone to use for Dataflow. This may be required if it's not set at the provider level, or that zone doesn't support Dataflow regional endpoints (see https://cloud.google.com/dataflow/docs/concepts/regional-endpoints)"
  default     = ""
}

variable "dataflow_region" {
  description = "The region to use for Dataflow. This may be required if it's not set at the provider level, or you want to use a region different from the zone (see https://cloud.google.com/dataflow/docs/concepts/regional-endpoints)"
  default     = ""
}

variable "dataflow_output_directory" {
  description = "A gs bucket location for storing output files by Google Dataflow, e.g. gs://myBucket/hedwigBackup"
  default     = ""
}

variable "dataflow_output_filename_prefix" {
  description = "Filename prefix for output files by Google Dataflow (defaults to subscription name)"
  default     = ""
}

variable "iam_service_accounts" {
  description = "(DEPRECATED: use members instead) The list of IAM service accounts to create exclusive IAM permissions for the topic. Flattens a list of list if necessary."
  default     = []
}

variable "iam_members" {
  description = "The list of IAM members to create exclusive IAM permissions for the topic. Flattens a list of list if necessary. The values must include appropriate IAM prefix, e.g. `group:` for google groups."
  default     = []
}

variable "enable_alerts" {
  description = "Should alerting be generated?"
  type        = bool
  default     = false
}

variable "alerting_project" {
  description = "The project where alerting resources should be created (defaults to current project)"
  default     = ""
}

variable "dataflow_freshness_alert_threshold" {
  description = "Threshold for alerting on Dataflow freshness in seconds"
  default     = 1800 # 30 mins
}

variable "dataflow_freshness_alert_notification_channels" {
  description = "Stackdriver Notification Channels for dataflow alarm for freshness (required if alerting is on)"
  type        = list(string)
  default     = []
}
