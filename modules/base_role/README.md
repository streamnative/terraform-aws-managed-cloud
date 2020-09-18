# Role resource for AWS

This terraform module either creates a role or references  
an existing role and attaches the specified policy.  
This is primarily to be used by other modules

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
| assume\_role\_policy | the assume role policy, if not provided, defaults to just be for ec2 service | `string` | `""` | no |
| existing\_role\_name | an optional existing role name, if not provided, a role with role\_name will be created | `string` | `""` | no |
| role\_name | the name of the role to be created (if existing\_role\_name is not provided) | `any` | n/a | yes |
| role\_policy | the default policy to be added for the role, or an additional policy to attach to the existing role name | `string` | `"{}"` | no |
| role\_policy\_name | the name of the role policy attachment | `any` | n/a | yes |
| role\_tags | tags to be added to the role (if not an existing role | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| role\_arn | the arn of the role |
| role\_name | the name of the role |

