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
 *     Enviroment: "Production"
 *   }
 *   # attach policy to existing role
 *   existing_role_name = "my-existing-cluster-role"
 * }
 * ```
 */
terraform {
  required_providers {
    aws = {
      version = ">= 2.70.0"
      source  = "hashicorp/aws"
    }
  }
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

data "aws_iam_policy_document" "role_policy" {
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

module "role" {
  source             = "../aws_role"
  existing_role_name = var.existing_role_name
  role_name          = var.role_name

  role_policy_name = "${var.prefix}-vault-resources"
  role_policy      = data.aws_iam_policy_document.role_policy.json

}


output "role_name" {
  value       = module.role.role_name
  description = "the name of the role"
}

output "role_arn" {
  value       = module.role.role_arn
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
