# Bootstrap Role

This IAM role is to be assumed by streamnative for bootstrapping AWS resources.

See the bootstrap policy module for details on the permissions

```
module "bootstrap_role" {
  source = "streamnative/managed-cloud/aws//bootstrap_role"
  role_name = "streamnative-bootstrap"
  streamnative_arns = ["<to be provided by streamnative>"]

  # streamnative will need to know these prefixes
  s3_bucket_prefix = "myproject-sn-cloud-"
  dynamo_table_prefix = "myproject-sn-cloud-"
  kms_alias_prefix = "myproject-sn-cloud-"

  tags = {
    Project = "Pulsar"
    Environment = "Prod"
  }
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
| allowed\_regions | if you want to constrain this role to a given region, specify this property, otherwise, all regions are allowed | `string` | `"*"` | no |
| dynamo\_table\_prefix | a prefix that can limit the tables this role can manage | `string` | `""` | no |
| kms\_alias\_prefix | a prefix that can limit the kms aliases this role can manage | `string` | `""` | no |
| policy\_name | the name of the policy, defaults to same as role\_name | `string` | `""` | no |
| role\_name | the name of the role to be created | `any` | n/a | yes |
| s3\_bucket\_prefix | a prefix that can limit the buckets this role can manage | `string` | `""` | no |
| streamnative\_arns | the arns to grant assume role to, will be principals from streamnative | `any` | n/a | yes |
| tags | the tags to add to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| policy\_document | the text of the policy |
| policy\_name | the name of the policy |
| role\_arn | the arn of the role |
| role\_name | the name of the role |

