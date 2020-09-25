# Bootstrap Policy

This terraform module creates an IAM policy that contains  
the permissions needed to bootstrap the underlying AWS resources  
needed for a StreamNative cluster, but is *not* used to provision or manage  
the cluster itself, see the Management policy for details on that policy.

As different customers have different needs, this policy is configurable  
with different levels of access being given based on the options

The primary options are as follows, listed in order of increasing access:
- `allow_iam_policy_create`, this is needed for us to manage policies for resources created, but does not include the ability to actually attach those policies
- `allow_vault_management` (and `dynamo_table_prefix`, and `kms_alias_prefix`) allows for managing dynamo and kms key/alias (with optional prefix)
- `allow_tiered_storage_management` (and `s3_bucket_prefix`) allows for managing an s3 bucket with optional prefix
- `allow_eks_management`, this gives a broad set of permissions, including most of ec2, VPC and IAM, for managing EKS clusters and networks. IAM is namespced to `eksctl` roles
- `allow_iam_management`, gives access to create and attach iam roles and policies arbitrarily

NOTE: the `allow_eks_creation` is not currently as constrained as it can be, we will continue  
to reduce the needed permissions.

You can simply create this policy and attach to any role/user *or* use the `bootstrap_role` module  
which creates the role with the needed permissions for streamnative to assume the role.

Example:
```
module "bootstrap_policy" {
  source = "streamnative/managed-cloud/aws//bootstrap_policy"
  policy_name = "streamnative-bootstrap-policy"
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
| allow\_eks\_management | will grant this policy all permissions need to create and manage EKS clusters, which includes EC2, VPC, and many other permissions | `bool` | `false` | no |
| allow\_iam\_management | will grant this policy IAM permissions to create and manage roles and policies, which can allow privilege escalation | `bool` | `false` | no |
| allow\_iam\_policy\_create | will grant this policy the permission to create IAM policies, which is required by some of our modules, but not actually the ability to attach those policies | `bool` | `true` | no |
| allow\_tiered\_storage\_management | will grant this policy permisions to manage an s3 bucket, which can be limited by `s3_bucket_prefix` option | `bool` | `true` | no |
| allow\_vault\_management | will grant this policy permisions to manage a dynamo table and KMS key/alias, which can be limited by `dynamo_table_prefix` and `kms_alias_prefix` options respectively | `bool` | `true` | no |
| allowed\_regions | if you want to constrain this role to a given region, specify this property, otherwise, all regions are allowed | `string` | `"*"` | no |
| dynamo\_table\_prefix | a prefix that can limit the tables this role can manage | `string` | `""` | no |
| kms\_alias\_prefix | a prefix that can limit the kms aliases this role can manage | `string` | `""` | no |
| policy\_name | the name of policy to be created | `any` | n/a | yes |
| s3\_bucket\_prefix | a prefix that can limit the buckets this role can manage | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| policy\_arn | the arn of the policy |
| policy\_document | the policy document |
| policy\_name | the name of the policy |

