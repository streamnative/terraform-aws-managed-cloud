/**
 * # Management Role
 *
 * This IAM role is to be assumed by streamnative for management and provisoning of Pulsar clusters
 *
 * See the management policy module for details on the permissions
 *
 * ```
 * module "mangement_role" {
 *   source = "streamnative/managed-cloud/aws//mangement_role"
 *   role_name = "streamnative-management"
 *   streamnative_arns = ["<to be provided by streamnative>"]
 *
 *   nodegroup_arns = ["<arn of nodegroups>"]
 *   asg_arns = ["<arn of asgs>"]
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

variable "nodegroup_arns" {
  description = "the arns of the allowed EKS nodegroup's to manage"
  type        = list(string)
  default     = ["*"]
}

variable "asg_arns" {
  description = "the arns of the allowed ASG groups"
  type        = list(string)
  default     = ["*"]
}


module "role" {
  source    = "../streamnative_role"
  role_name = var.role_name
  tags      = var.tags

  assume_role_principals = var.streamnative_arns
}

module "policy" {
  source      = "../management_policy"
  policy_name = coalesce(var.policy_name, var.role_name)


  nodegroup_arns = var.nodegroup_arns
  asg_arns       = var.asg_arns
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
