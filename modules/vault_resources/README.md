# Hashicorp Vault resources for AWS

This terraform module creates the resources needed  
for running hashicorp vault on AWS, this includes  
a dynamodb table, kms key, and the needed IAM policies.

This policy can be attached either to an existing role or  
this module can optionally create new role with this policy attached

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
| dynamo\_billing\_mode | the billing mode for the dynamodb table that will be created | `string` | `"PAY_PER_REQUEST"` | no |
| dynamo\_provisioned\_capacity | when using "PROVISIONED" billing mode, the specified values will be use for throughput, in all other modes they are ignored | <pre>object({<br>    read  = number,<br>    write = number<br>  })</pre> | <pre>{<br>  "read": 10,<br>  "write": 10<br>}</pre> | no |
| existing\_role\_name | an optional existing role name to attach the policy to | `string` | `""` | no |
| new\_role\_name | the name of the role to be created and policy to attach to | `string` | `""` | no |
| prefix | the prefix to use for creating the resources associated with this module | `any` | n/a | yes |
| resource\_tags | tags that will be added to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| dynamo\_table\_arn | the arn of the dynamodb table used by vault |
| dynamo\_table\_name | the name of the dynamodb table used by vault |
| kms\_key\_alias\_arn | the arn of the kms key alias used by vault |
| kms\_key\_alias\_name | the name of the kms key alias used by vault |
| kms\_key\_target\_arn | the arn of the kms key used by vault |
| policy\_arn | n/a |
| policy\_document | n/a |
| policy\_name | n/a |
| role\_arns | the arns of the roles |
| role\_names | the names of the roles |

