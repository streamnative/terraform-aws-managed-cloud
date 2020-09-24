/**
 * # Policy/Role resource for AWS
 *
 * This terraform module creates a managed policy and can be configured
 * to either take no further action (if both `new_role_name` and `existing_role_name` are empty)
 * to attach to an existing role (if `existing_role_name` is set)
 * or to create a new role and attach (if `new_role_name` is set)
 * if both existing_role_name and new_role_name are provided, a new role is created and both
 * the new and existing roles will get an attachment
 * This is primarily to be used by other modules
 */
terraform {
  required_providers {
    aws = {
      version = ">= 2.70.0"
      source  = "hashicorp/aws"
    }
  }
}

variable "role_tags" {
  description = "tags to be added to the role (if not an existing role"
  default     = {}
  type        = map(string)
}

variable "policy_name" {
  description = "the name of the managed policy to be created and name given to attached policy"
}

variable "existing_role_name" {
  description = "an optional existing role name, if not provided, a role with role_name will be created"
  default     = ""
}

variable "new_role_name" {
  description = "the name of the role to be created (if existing_role_name is not provided)"
  default     = ""
}

variable "role_policy" {
  description = "the default policy to be added for the role, or an additional policy to attach to the existing role name"
  default     = "{}"
}

variable "assume_role_policy" {
  description = "the assume role policy, if not provided, defaults to just be for ec2 service"
  default     = ""
}

locals {
  assume_role_policy = coalesce(var.assume_role_policy, data.aws_iam_policy_document.default_assume.json)

  role_names = concat(data.aws_iam_role.existing.*.name, aws_iam_role.role.*.name)
  role_arns  = concat(data.aws_iam_role.existing.*.arn, aws_iam_role.role.*.arn)
}

data "aws_iam_policy_document" "default_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role" {
  count              = var.new_role_name != "" ? 1 : 0
  name               = var.new_role_name
  assume_role_policy = local.assume_role_policy
}

data "aws_iam_role" "existing" {
  count = var.existing_role_name != "" ? 1 : 0
  name  = var.existing_role_name
}


resource "aws_iam_instance_profile" "role" {
  count = var.new_role_name != "" ? 1 : 0
  name  = var.new_role_name
  role  = var.new_role_name
}

resource "aws_iam_policy" "policy" {
  name = var.policy_name

  policy = var.role_policy
}

resource "aws_iam_role_policy_attachment" "attach_existing" {
  count      = var.existing_role_name != "" ? 1 : 0
  role       = var.existing_role_name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_new" {
  count      = var.new_role_name != "" ? 1 : 0
  role       = var.new_role_name
  policy_arn = aws_iam_policy.policy.arn
}

output "role_names" {
  value       = local.role_names
  description = "the names of the roles, may be empty"
}

output "role_arns" {
  value       = local.role_arns
  description = "the arns of the roles, may be empty"
}

output "policy_name" {
  value       = aws_iam_policy.policy.name
  description = "the name of the policy created"
}

output "policy_arn" {
  value       = aws_iam_policy.policy.arn
  description = "the arn of the policy created"
}
