/**
 * # Streamnative Role
 *
 * This terraform module either creates a role that will be assumed
 * by streamnative
 */
terraform {
  required_providers {
    aws = {
      version = ">= 2.70.0"
      source  = "hashicorp/aws"
    }
  }
}

variable "tags" {
  description = "tags to be added to the role"
  default     = {}
  type        = map(string)
}

variable "role_name" {
  description = "the name of the role to be created"
}

variable "assume_role_principals" {
  description = "the principal that will be allowed to assume this role, will be provided by streamnative"
  type        = list(string)
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"

      identifiers = var.assume_role_principals
    }
  }
}


resource "aws_iam_role" "role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}



output "role_name" {
  value       = aws_iam_role.role.name
  description = "the name of the role"
}

output "role_arn" {
  value       = aws_iam_role.role.arn
  description = "the arn of the role"
}
