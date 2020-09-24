# Management Policy

This terraform module creates an IAM policy that contains  
all of the permissions needed to manage and deploy a StreamNative Cloud cluster.  
It does not have all the permissions needed to create underlying resources, see  
bootstrap policy module

NOTE: this policy is not currently as constrained as it can be, we will continue  
to reduce the needed permissions.

This policy primarily includes the ability to:
* read only access to EC2, VPC, cloudwatch, etc
* EKS nodegroup edit permissions
* ASG edit permissions

Example:
```
module "manager_policy" {
  source = "streamnative/managed-cloud/aws//management_policy"
  policy_name = "streamnative-management-policy"
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
| asg\_arns | the arns of the allowed ASG groups | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| nodegroup\_arns | the arns of the allowed EKS nodegroup's to manage | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| policy\_name | the name of policy to be created | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| policy\_arn | the arn of the policy |
| policy\_document | the policy document |
| policy\_name | the name of the policy |

