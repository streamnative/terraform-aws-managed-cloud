## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_name | the name of the s3 bucket | `any` | n/a | yes |
| bucket\_tags | the tags to add to the bucket | `list` | `[]` | no |
| existing\_role\_name | an optional existing role name, if not provided, a role with role\_name will be created | `string` | `""` | no |
| role\_name | the name of the role to be created (if existing\_role\_name is not provided) | `string` | `"pulsar-offload-role"` | no |

## Outputs

| Name | Description |
|------|-------------|
| role\_arn | the arn of the role |
| role\_name | the name of the role |
| s3\_bucket | n/a |
| s3\_bucket\_arn | n/a |

