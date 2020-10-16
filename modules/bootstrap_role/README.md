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
| allow\_acm\_certificate\_management | will grant this policy IAM permissions to create ACM certificate and validate certificate through Route53 | `bool` | `true` | no |
| allow\_eks\_management | will grant this policy all permissions need to create and manage EKS clusters, which includes EC2, VPC, and many other permissions | `bool` | `false` | no |
| allow\_iam\_management | will grant this policy IAM permissions to create and manage roles and policies, which can allow privilege escalation | `bool` | `false` | no |
| allow\_iam\_policy\_create | will grant this policy the permission to create IAM policies, which is required by some of our modules, but not actually the ability to attach those policies | `bool` | `true` | no |
| allow\_tiered\_storage\_management | will grant this policy permisions to manage an s3 bucket, which can be limited by `s3_bucket_prefix` option | `bool` | `true` | no |
| allow\_vault\_management | will grant this policy permisions to manage a dynamo table and KMS key/alias, which can be limited by `dynamo_table_prefix` and `kms_alias_prefix` options respectively | `bool` | `true` | no |
| allowed\_regions | if you want to constrain this role to a given region, specify this property, otherwise, all regions are allowed | `string` | `"*"` | no |
| dynamo\_table\_prefix | a prefix that can limit the tables this role can manage | `string` | `""` | no |
| hostedzones\_arns | the arns of the allowed hostedzones | `list(string)` | <pre>[<br>  "arn:aws:route53:::hostedzone/*"<br>]</pre> | no |
| kms\_alias\_prefix | a prefix that can limit the kms aliases this role can manage | `string` | `""` | no |
| policy\_name | the name of the policy, defaults to same as role\_name | `string` | `""` | no |
| role\_name | the name of the role to be created | `any` | n/a | yes |
| s3\_bucket\_prefix | a prefix that can limit the buckets this role can manage | `string` | `""` | no |
| streamnative\_arns | the arns to grant assume role to, will be principals from streamnative | `any` | n/a | yes |
| tags | the tags to add to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| policy\_arn | the arn of the policy |
| policy\_document | the text of the policy |
| policy\_name | the name of the policy |
| role\_arn | the arn of the role |
| role\_name | the name of the role |

