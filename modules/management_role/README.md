# Management Role

This IAM role is to be assumed by streamnative for management and provisoning of Pulsar clusters

See the management policy module for details on the permissions

```
module "mangement_role" {
  source = "streamnative/managed-cloud/aws//mangement_role"
  role_name = "streamnative-management"
  streamnative_arns = ["<to be provided by streamnative>"]

  nodegroup_arns = ["<arn of nodegroups>"]
  asg_arns = ["<arn of asgs>"]

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
| allow\_asg\_management | will grant this policy the permission to update asg (specified in asg\_arns) | `bool` | `true` | no |
| allow\_nodegroup\_management | will grant this policy the permission to update nodegroups (specified in nodegroup\_arns) | `bool` | `true` | no |
| asg\_arns | the arns of the allowed ASG groups | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| nodegroup\_arns | the arns of the allowed EKS nodegroup's to manage | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| policy\_name | the name of the policy, defaults to same as role\_name | `string` | `""` | no |
| role\_name | the name of the role to be created | `any` | n/a | yes |
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

