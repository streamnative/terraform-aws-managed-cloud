# DEPRECATED - PLEASE USE https://github.com/streamnative/terraform-aws-cloud INSTEAD

# AWS StreamNative Managed Cloud Modules
This repo contains terraform scripts that can be used to provision resources needed for StreamNative Managed Cloud in AWS

The top level module in this repo serves as an example, the module contained in the `modules/` folder can be used to enable the features you require in streamnative cloud.

## Components

Documentation for all the inputs and outputs for each of these modules can be found in README.md in the respective modules folder.

### Tiered Storage

See `modules/tiered_storage` for the terraform script. This creates an S3 bucket, a policy, and optionally either creates an IAM role/instance profile or is attached to an existing IAM role.

This role should be the instance profile that is used for your Pulsar brokers.

### Vault Resources

See `modules/vault_resources`. This creates a dynamodb table and KMS key needed for the vault instance running in your managed cluster. It also generates the proper IAM policy, which can either be attached to an existing role or provision a new role specifically for these needs.

### ACM Certificate Resources

See `modules/acm_certificate`. This creates a ACM certificate needed for provisioning load balancers for your managed Pulsar cluster.
