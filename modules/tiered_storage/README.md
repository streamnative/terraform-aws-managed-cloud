# Tiered Storage for AWS

This terraform module creates the needed s3 bucket  
and IAM policies, plus role creation/attachment  
that is needed for storage offloading in Pulsar.

This bucket also enables bucket encrpytion by default

See the parameters for full details but here is an example usage:

```
module "tiered_storage" {
  source = "streamnative/managed-cloud/aws//tiered_storage"
  bucket_name = "myorg-pulsar-offload-us-east-1"
  bucket_tags = {
    Project = "MyApp"
    Environment = "Prod"
  }
  # attach policy to existing role
  existing_role_name = "my-pulsar-cluster-role"
}
```

## Requirements

| Name | Version |
|------|---------|
| aws | >= 2.70.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_name | the name of the s3 bucket | `any` | n/a | yes |
| bucket\_tags | the tags to add to the bucket | `map(string)` | `{}` | no |
| existing\_role\_name | an optional existing role name to attach the policy to | `string` | `""` | no |
| new\_role\_name | an optional role name to create and attach the policy to | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| policy\_arn | n/a |
| policy\_document | n/a |
| policy\_name | n/a |
| role\_arn | the arns of the roles |
| role\_names | the names of the roles |
| s3\_bucket | the name of the bucket used for offloading |
| s3\_bucket\_arn | the arn of the bucket used for offloading |

