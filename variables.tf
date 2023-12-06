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

variable "iam_service_accounts" {
  description = "(DEPRECATED: use members instead) The list of IAM service accounts to create exclusive IAM permissions for the topic. Flattens a list of list if necessary."
  default     = []
}

variable "iam_members" {
  description = "The list of IAM members to create exclusive IAM permissions for the topic. Flattens a list of list if necessary. The values must include appropriate IAM prefix, e.g. `group:` for google groups."
  default     = []
}
