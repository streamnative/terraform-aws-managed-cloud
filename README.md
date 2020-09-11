# managed-cloud-provisioning
This repo contains terraform scripts that can be used to provision resources needed for StreamNative Managed Cloud

All of these terraform scripts should be suitable for usage as terraform modules that you can import in your own repo.


## Components

Documentation for all the inputs and outputs for each of these modules can be found in `docs/`

### Tiered Storage in AWS

See `provision/aws_tiered_storage` for the terraform script. This creates an S3 bucket, a policy, and optionally either creates an IAM role/instance profile or is attached to an existing IAM role.

This role should be the instance profile that is used for your Pulsar brokers.


