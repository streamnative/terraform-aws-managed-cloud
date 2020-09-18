/**
 * # Role resource for AWS
 *
 * This terraform module either creates a role or references
 * an existing role and attaches the specified policy.
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

variable "existing_role_name" {
  description = "an optional existing role name, if not provided, a role with role_name will be created"
  default     = ""
}

variable "role_name" {
  description = "the name of the role to be created (if existing_role_name is not provided)"
}

variable "role_policy" {
  description = "the default policy to be added for the role, or an additional policy to attach to the existing role name"
  default     = "{}"
}

variable "role_policy_name" {
  description = "the name of the role policy attachment"
}

variable "assume_role_policy" {
  description = "the assume role policy, if not provided, defaults to just be for ec2 service"
  default     = ""
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

locals {
  assume_role_policy = coalesce(var.assume_role_policy, data.aws_iam_policy_document.default_assume.json)
}

resource "aws_iam_role" "role" {
  count              = var.existing_role_name != "" ? 0 : 1
  name               = var.role_name
  assume_role_policy = local.assume_role_policy
}

data "aws_iam_role" "existing" {
  count = var.existing_role_name != "" ? 1 : 0
  name  = var.existing_role_name
}

locals {
  role_name = var.existing_role_name != "" ? element(data.aws_iam_role.existing.*.name, 0) : element(aws_iam_role.role.*.name, 0)
  role_arn  = var.existing_role_name != "" ? element(data.aws_iam_role.existing.*.arn, 0) : element(aws_iam_role.role.*.arn, 0)
}

resource "aws_iam_instance_profile" "role" {
  count = var.existing_role_name != "" ? 0 : 1
  name  = local.role_name
  role  = local.role_name
}

resource "aws_iam_role_policy" "role_policy" {
  name = var.role_policy_name
  role = local.role_name

  policy = var.role_policy
}

output "role_name" {
  value       = local.role_name
  description = "the name of the role"
}

output "role_arn" {
  value       = local.role_arn
  description = "the arn of the role"
}
