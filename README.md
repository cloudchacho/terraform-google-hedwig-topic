Hedwig Topic Terraform module
=============================

[Hedwig](https://github.com/Automatic/hedwig) is a inter-service communication bus that works on Google Pub/Sub, while keeping things pretty simple and
straight forward. It uses [json schema](http://json-schema.org/) draft v4 for schema validation so all incoming
and outgoing messages are validated against pre-defined schema.

This module provides a custom [Terraform](https://www.terraform.io/) modules for deploying Hedwig infrastructure that
creates Hedwig topics.

## Usage

```hcl
module "topic-dev-user-updated" {
  source = "cloudchacho/hedwig-topic/google"
  topic  = "dev-user-updated-v1"
}
```

It's recommended that `topic` include your environment, as well as a major version for the message schema. For 
example, [JSON Schema](http://json-schema.org/) is a good way to version message content while also keeping it 
human-readable. 

Naming convention - lowercase alphanumeric and dashes only. The Pub/Sub topic name will be prefixed by `hedwig-`.

Please note Google's restrictions (if not followed, errors may be confusing and often totally wrong):
- [Resource names](https://cloud.google.com/pubsub/docs/admin#resource_names) 

### Firehose

To _firehose_—read as, _save_—messages to Google Cloud Storage (GCS), use the _`firehose_config`_ setting like the following example illustrates:

```hcl
module "topic-dev-user-updated" {
  source = "cloudchacho/hedwig-topic/google"
  topic  = "dev-user-updated-v1"
  firehose_config = {
    enabled = true
    bucket = "mybucket"
  }
}
```

The result will be an additional [_Pub/Sub Cloud Storage_](https://cloud.google.com/pubsub/docs/create-cloudstorage-subscription) subscription that saves messages to GCS.

Naming convention - The additional subscription has `hedwig-` prefix and `-firehose` suffix; for example, the earlier example creates a `hedwig-dev-user-updated-v1` topic and `hedwig-dev-user-updated-v1-firehose` subscription. See caveats for GCS bucket creation and Identity and Access Management (IAM) permissions prerequisites.

## Caveats

### GCS and IAM

If you're using the _`firehose_config`_ setting to save messages to a Google Cloud Storage (GCS) bucket, then do the following GCS and Identity and Access Management (IAM) tasks before applying:

1. Create your GCS bucket.
2. Configure IAM permissions. This is a complicated task where you choose to grant permissions at either the bucket level or project level; for details, see [_Assign Cloud Storage roles to the Pub/Sub service account_](https://cloud.google.com/pubsub/docs/create-cloudstorage-subscription#assign_roles_cloudstorage) Google docs page.

## Release Notes

[Github Releases](https://github.com/cloudchacho/terraform-google-hedwig-topic/releases)

## How to publish

Go to [Terraform Registry](https://registry.terraform.io/modules/cloudchacho/hedwig-topic/google), and Resync module.
