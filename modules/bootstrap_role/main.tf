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
  type        = string
}

variable "policy_name" {
  description = "the name of the policy, defaults to same as role_name"
  default     = ""
  type        = string
}

variable "streamnative_arns" {
  description = "the arns to grant assume role to, will be principals from streamnative"
  type        = string
}

variable "allow_iam_policy_create" {
  description = "will grant this policy the permission to create IAM policies, which is required by some of our modules, but not actually the ability to attach those policies"
  type        = bool
  default     = true
}

variable "allow_vault_management" {
  description = "will grant this policy permisions to manage a dynamo table and KMS key/alias, which can be limited by `dynamo_table_prefix` and `kms_alias_prefix` options respectively"
  type        = bool
  default     = true
}

variable "allow_tiered_storage_management" {
  description = "will grant this policy permisions to manage an s3 bucket, which can be limited by `s3_bucket_prefix` option"
  type        = bool
  default     = true
}

variable "allow_eks_management" {
  description = "will grant this policy all permissions need to create and manage EKS clusters, which includes EC2, VPC, and many other permissions"
  type        = bool
  default     = false
}

variable "allow_iam_management" {
  description = "will grant this policy IAM permissions to create and manage roles and policies, which can allow privilege escalation"
  type        = bool
  default     = false
}

variable "allow_acm_certificate_management" {
  description = "will grant this policy IAM permissions to create ACM certificate and validate certificate through Route53"
  type        = bool
  default     = true
}

variable "s3_bucket_prefix" {
  description = "a prefix that can limit the buckets this role can manage"
  default     = ""
  type        = string
}

variable "dynamo_table_prefix" {
  description = "a prefix that can limit the tables this role can manage"
  default     = ""
  type        = string
}

variable "kms_alias_prefix" {
  description = "a prefix that can limit the kms aliases this role can manage"
  default     = ""
  type        = string
}

variable "allowed_regions" {
  description = "if you want to constrain this role to a given region, specify this property, otherwise, all regions are allowed"
  default     = "*"
  type        = string
}

variable "hostedzones_arns" {
  description = "the arns of the allowed hostedzones"
  type        = list(string)
  default     = ["arn:aws:route53:::hostedzone/*"]
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

  allow_iam_policy_create          = var.allow_iam_policy_create
  allow_vault_management           = var.allow_vault_management
  allow_tiered_storage_management  = var.allow_tiered_storage_management
  allow_eks_management             = var.allow_eks_management
  allow_iam_management             = var.allow_iam_management
  allow_acm_certificate_management = var.allow_acm_certificate_management

  s3_bucket_prefix    = var.s3_bucket_prefix
  dynamo_table_prefix = var.dynamo_table_prefix
  kms_alias_prefix    = var.kms_alias_prefix
  allowed_regions     = var.allowed_regions
  hostedzones_arns    = var.hostedzones_arns
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
