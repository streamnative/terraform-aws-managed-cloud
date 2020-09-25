# Policy/Role resource for AWS

This terraform module creates a managed policy and can be configured  
to either take no further action (if both `new_role_name` and `existing_role_name` are empty)  
to attach to an existing role (if `existing_role_name` is set)  
or to create a new role and attach (if `new_role_name` is set)  
if both existing\_role\_name and new\_role\_name are provided, a new role is created and both  
the new and existing roles will get an attachment  
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
| new\_role\_name | the name of the role to be created (if existing\_role\_name is not provided) | `string` | `""` | no |
| policy\_name | the name of the managed policy to be created and name given to attached policy | `any` | n/a | yes |
| role\_policy | the default policy to be added for the role, or an additional policy to attach to the existing role name | `string` | `"{}"` | no |
| role\_tags | tags to be added to the role (if not an existing role | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| policy\_arn | the arn of the policy created |
| policy\_name | the name of the policy created |
| role\_arns | the arns of the roles, may be empty |
| role\_names | the names of the roles, may be empty |

