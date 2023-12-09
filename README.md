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

## Caveats

### IAM

If you're using Terraform to create the Dataflow output GCS bucket, then ensure that permissions for the bucket 
include `Storage Legacy Object Owner` or `Storage Object Admin`. This is done by default if using
Google Console, but not for Terraform. This can be done in Terraform like so:

```hcl
data google_project current {}

resource "google_storage_bucket_iam_member" "hedwig_firehose_editor_iam" {
  bucket = "${google_storage_bucket.hedwig_firehose.name}"
  role   = "roles/storage.admin"
  member = "projectEditor:${data.google_project.current.id}"
}

resource "google_storage_bucket_iam_member" "hedwig_firehose_owner_iam" {
  bucket = "${google_storage_bucket.hedwig_firehose.name}"
  role   = "roles/storage.admin"
  member = "projectOwner:${data.google_project.current.id}"
}
```

Alternatively, you can restrict these permissions to the user Dataflow uses, which is: `{project number}-compute@developer.gserviceaccount.com`.

## Release Notes

[Github Releases](https://github.com/cloudchacho/terraform-google-hedwig-topic/releases)

## How to publish

Go to [Terraform Registry](https://registry.terraform.io/modules/cloudchacho/hedwig-topic/google), and Resync module.
