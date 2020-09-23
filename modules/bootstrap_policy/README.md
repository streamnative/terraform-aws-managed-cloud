# Bootstrap Policy

This terraform module creates an IAM policy that contains  
all of the permissions needed to bootstrap the underlying AWS resources  
needed for a StreamNative cluster, but is *not* used to provision or manage  
the cluster itself, see the Management policy for details on that policy.

NOTE: this policy is not currently as constrained as it can be, we will continue  
to reduce the needed permissions. Additionally, this is based of eksctl permissions  
which we will slowly reduce

This policy primarily includes the ability to:
* manage many ec2, cloudformation, eks, and IAM permissions
* create/delete/update dynamodb tables
* create/delete/update S3 buckets
* create/delete/update KMS keys and aliases

These permissions can optionally be constrainted (where applicable)  
by allowing it only to manage a prefix of resources (for s3 buckets, dynamodb tables)

This policy is not intended for usage  
with the administration/provisioning of the actual StreamNative cluster,  
where we use a much more constrained policy, this is just for bootsrapping

You can simply create this policy and attach to any role *or* use the `bootstrap_role` module  
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
| allowed\_regions | if you want to constrain this role to a given region, specify this property, otherwise, all regions are allowed | `string` | `"*"` | no |
| dynamo\_table\_prefix | a prefix that can limit the tables this role can manage | `string` | `""` | no |
| kms\_alias\_prefix | a prefix that can limit the kms aliases this role can manage | `string` | `""` | no |
| policy\_name | the name of policy to be created | `any` | n/a | yes |
| s3\_bucket\_prefix | a prefix that can limit the buckets this role can manage | `string` | `""` | no |
| tags | tags to be added to the policy | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| policy\_document | the policy document |
| policy\_name | the name of the policy |

