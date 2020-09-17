# Hashicorp Vault resources for AWS

This terraform module creates the resources needed  
for running hashicorp vault on AWS, this includes  
a dynamodb table, kms key, and the needed IAM policies.

This policy can be attached either to an existing role or  
this module can optionally create new role with this policy attached

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dynamo\_billing\_mode | the billing mode for the dynamodb table that will be created | `string` | `"PAY_PER_REQUEST"` | no |
| dynamo\_provisioned\_capacity | when using "PROVISIONED" billing mode, the specified values will be use for throughput, in all other modes they are ignored | <pre>object({<br>    read  = number,<br>    write = number<br>  })</pre> | <pre>{<br>  "read": 10,<br>  "write": 10<br>}</pre> | no |
| existing\_role\_name | an optional existing role name, if not provided, a role with role\_name will be created | `string` | `""` | no |
| prefix | the prefix to use for creating the resources associated with this module | `any` | n/a | yes |
| resource\_tags | tags that will be added to resources | `map(string)` | `{}` | no |
| role\_name | the name of the role to be created (if existing\_role\_name is not provided) | `string` | `"pulsar-vault-role"` | no |

## Outputs

| Name | Description |
|------|-------------|
| dynamo\_table\_arn | the arn of the dynamodb table used by vault |
| dynamo\_table\_name | the name of the dynamodb table used by vault |
| kms\_key\_alias\_arn | the arn of the kms key alias used by vault |
| kms\_key\_alias\_name | the name of the kms key alias used by vault |
| kms\_key\_target\_arn | the arn of the kms key used by vault |
| role\_arn | the arn of the role |
| role\_name | the name of the role |

