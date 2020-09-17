/**
 * # Hashicorp Vault resources for AWS
 *
 * This terraform module creates the resources needed
 * for running hashicorp vault on AWS, this includes
 * a dynamodb table, kms key, and the needed IAM policies.
 *
 * This policy can be attached either to an existing role or
 * this module can optionally create new role with this policy attached

 * See the parameters for full details but here is an example usage:
 *
 * ```
 * module "aws_vault" {
 *   source = "provision/aws_vault_resources"
 *   prefix = "myorg-prod"
 *   resource_tags = {
 *     Enviroment => "Production"
 *   }
 *   # attach policy to existing role
 *   existing_role_name = "my-existing-cluster-role"
 * }
 * ```
 */
provider "aws" {
}

variable "prefix" {
  description = "the prefix to use for creating the resources associated with this module"
}

variable "resource_tags" {
  description = "tags that will be added to resources"
  default     = {}
  type        = map(string)
}

variable "existing_role_name" {
  description = "an optional existing role name, if not provided, a role with role_name will be created"
  default     = ""
}

variable "role_name" {
  description = "the name of the role to be created (if existing_role_name is not provided)"
  default     = "pulsar-vault-role"
}

variable "dynamo_billing_mode" {
  description = "the billing mode for the dynamodb table that will be created"
  default     = "PAY_PER_REQUEST"
}
variable "dynamo_provisioned_capacity" {
  description = "when using \"PROVISIONED\" billing mode, the specified values will be use for throughput, in all other modes they are ignored"
  type = object({
    read  = number,
    write = number
  })
  default = {
    read : 10,
    write : 10
  }
}

resource "aws_dynamodb_table" "vault_table" {
  name         = "${var.prefix}-vault-table"
  billing_mode = var.dynamo_billing_mode
  hash_key     = "Path"
  range_key    = "Key"

  attribute {
    name = "Path"
    type = "S"
  }
  attribute {
    name = "Key"
    type = "S"
  }

  write_capacity = var.dynamo_provisioned_capacity.write
  read_capacity  = var.dynamo_provisioned_capacity.read

  tags = var.resource_tags
}

resource "aws_kms_key" "vault_key" {
  description = "Key for vault in streamnative pulsar cluster"
}

resource "aws_kms_alias" "vault_key" {
  name          = "alias/${var.prefix}-vault-key"
  target_key_id = aws_kms_key.vault_key.id
}

data "aws_iam_policy_document" "vault_policy" {
  // list and describe actions that are unqualified
  statement {
    actions = [
      "dynamodb:List*",
      "dynamodb:DescribeReservedCapacity*",
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive"
    ]

    resources = ["*"]
  }
  // dynamo actions
  statement {
    actions = [
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:ListTables",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:CreateTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:DescribeTable"
    ]

    resources = [aws_dynamodb_table.vault_table.arn]
  }
  // kms actions
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]

    resources = [aws_kms_key.vault_key.arn]
  }

}


resource "aws_iam_instance_profile" "vault_role" {
  count = var.existing_role_name != "" ? 0 : 1
  name  = element(aws_iam_role.vault_role.*.name, 0)
  role  = element(aws_iam_role.vault_role.*.name, 0)
}

resource "aws_iam_role" "vault_role" {
  count              = var.existing_role_name != "" ? 0 : 1
  name               = var.existing_role_name
  assume_role_policy = data.aws_iam_policy_document.vault_assume.json
}

resource "aws_iam_role_policy" "vault_policy" {
  name = "${var.prefix}-policy"
  role = coalesce(var.existing_role_name, element(aws_iam_role.vault_role.*.name, 0))

  policy = data.aws_iam_policy_document.vault_policy.json
}

data "aws_iam_policy_document" "vault_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_role" "existing" {
  count = var.existing_role_name != "" ? 1 : 0
  name  = var.existing_role_name
}


output "role_name" {
  value       = coalesce(var.existing_role_name, element(aws_iam_role.vault_role.*.name, 0))
  description = "the name of the role"
}

output "role_arn" {
  value       = coalesce(element(data.aws_iam_role.existing.*.arn, 0), element(aws_iam_role.vault_role.*.arn, 0))
  description = "the arn of the role"
}

output "dynamo_table_name" {
  value       = aws_dynamodb_table.vault_table.id
  description = "the name of the dynamodb table used by vault"
}
output "dynamo_table_arn" {
  value       = aws_dynamodb_table.vault_table.arn
  description = "the arn of the dynamodb table used by vault"
}
output "kms_key_alias_name" {
  value       = aws_kms_alias.vault_key.name
  description = "the name of the kms key alias used by vault"
}
output "kms_key_alias_arn" {
  value       = aws_kms_alias.vault_key.arn
  description = "the arn of the kms key alias used by vault"
}
output "kms_key_target_arn" {
  value       = aws_kms_key.vault_key.arn
  description = "the arn of the kms key used by vault"
}
