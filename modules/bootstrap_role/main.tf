/**
 * # Bootstrap Role
 *
 * This IAM role is to be assumed by streamnative for bootstrapping AWS resources.
 *
 * See the bootstrap policy module for details on the permissions
 *
 * ```
 * module "bootstrap_role" {
 *   source = "streamnative/managed-cloud/aws//bootstrap_role"
 *   role_name = "streamnative-bootstrap"
 *   streamnative_arns = ["<to be provided by streamnative>"]
 *
 *   # streamnative will need to know these prefixes
 *   s3_bucket_prefix = "myproject-sn-cloud-"
 *   dynamo_table_prefix = "myproject-sn-cloud-"
 *   kms_alias_prefix = "myproject-sn-cloud-"
 *
 *
 *   tags = {
 *     Project = "Pulsar"
 *     Environment = "Prod"
 *   }
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

variable "tags" {
  description = "the tags to add to the resources"
  default     = {}
  type        = map(string)
}

variable "role_name" {
  description = "the name of the role to be created"
}

variable "policy_name" {
  description = "the name of the policy, defaults to same as role_name"
  default     = ""
}

variable "streamnative_arns" {
  description = "the arns to grant assume role to, will be principals from streamnative"
}

variable "s3_bucket_prefix" {
  description = "a prefix that can limit the buckets this role can manage"
  default     = ""
}

variable "dynamo_table_prefix" {
  description = "a prefix that can limit the tables this role can manage"
  default     = ""
}

variable "kms_alias_prefix" {
  description = "a prefix that can limit the kms aliases this role can manage"
  default     = ""
}

variable "allowed_regions" {
  description = "if you want to constrain this role to a given region, specify this property, otherwise, all regions are allowed"
  default     = "*"
}


module "role" {
  source    = "../streamnative_role"
  role_name = var.role_name
  tags      = var.tags

  assume_role_principals = var.streamnative_arns
}

module "policy" {
  source      = "../bootstrap_policy"
  policy_name = coalesce(var.policy_name, var.role_name)


  s3_bucket_prefix    = var.s3_bucket_prefix
  dynamo_table_prefix = var.dynamo_table_prefix
  kms_alias_prefix    = var.kms_alias_prefix
  allowed_regions     = var.allowed_regions
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = module.role.role_name
  policy_arn = module.policy.policy_arn
}


output "role_name" {
  value       = module.role.role_name
  description = "the name of the role"
}

output "role_arn" {
  value       = module.role.role_arn
  description = "the arn of the role"
}

output "policy_name" {
  value       = module.policy.policy_name
  description = "the name of the policy"
}

output "policy_arn" {
  value       = module.policy.policy_arn
  description = "the arn of the policy"
}

output "policy_document" {
  value       = module.policy.policy_document
  description = "the text of the policy"
}
