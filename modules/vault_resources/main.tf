/**
 * # Hashicorp Vault resources for AWS
 *
 * This terraform module creates the resources needed
 * for running hashicorp vault on AWS, this includes
 * a dynamodb table, kms key, and the needed IAM policies.
 *
 * This policy can be attached either to an existing role or
 * this module can optionally create new role with this policy attached
 *
 * See the parameters for full details but here is an example usage:
 *
 * ```
 * module "aws_vault" {
 *   source = "streamnative/managed-cloud/aws//vault_resources"
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
  type        = string
}

variable "resource_tags" {
  description = "tags that will be added to resources"
  default     = {}
  type        = map(string)
}

variable "existing_role_name" {
  description = "an optional existing role name to attach the policy to"
  default     = ""
  type        = string
}

variable "new_role_name" {
  description = "the name of the role to be created and policy to attach to"
  default     = ""
  type        = string
}

variable "dynamo_billing_mode" {
  description = "the billing mode for the dynamodb table that will be created"
  default     = "PAY_PER_REQUEST"
  type        = string
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

  write_capacity = var.dynamo_billing_mode == "PROVISIONED" ? var.dynamo_provisioned_capacity.write : 0
  read_capacity  = var.dynamo_billing_mode == "PROVISIONED" ? var.dynamo_provisioned_capacity.read : 0

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
  source             = "../base_policy_role"
  existing_role_name = var.existing_role_name
  new_role_name      = var.new_role_name


  policy_name = "${var.prefix}-vault-resources"
  role_policy = data.aws_iam_policy_document.role_policy.json

}


output "role_names" {
  value       = module.role.role_names
  description = "the names of the roles"
}

output "role_arns" {
  value       = module.role.role_arns
  description = "the arns of the roles"
}

output "policy_name" {
  value = module.role.policy_name
}
output "policy_arn" {
  value = module.role.policy_arn
}

output "policy_document" {
  value = data.aws_iam_policy_document.role_policy.json
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
