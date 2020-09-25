# Streamnative Role

This terraform module either creates a role that will be assumed  
by streamnative

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
| assume\_role\_principals | the principal that will be allowed to assume this role, will be provided by streamnative | `list(string)` | n/a | yes |
| role\_name | the name of the role to be created | `any` | n/a | yes |
| tags | tags to be added to the role | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| role\_arn | the arn of the role |
| role\_name | the name of the role |

