/**
 * # Management Policy
 *
 * This terraform module creates an IAM policy that contains
 * all of the permissions needed to manage and deploy a StreamNative Cloud cluster.
 * It does not have all the permissions needed to create underlying resources, see
 * bootstrap policy module
 *
 * NOTE: this policy is not currently as constrained as it can be, we will continue
 * to reduce the needed permissions.
 *
 * This policy primarily includes the ability to:
 * * read only access to EC2, VPC, cloudwatch, etc
 * * EKS nodegroup edit permissions
 * * ASG edit permissions
 *
 * Example:
 * ```
 * module "manager_policy" {
 *   source = "streamnative/managed-cloud/aws//management_policy"
 *   policy_name = "streamnative-management-policy"
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

variable "policy_name" {
  description = "the name of policy to be created"
  type        = string
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

variable "allow_nodegroup_management" {
  description = "will grant this policy the permission to update nodegroups (specified in nodegroup_arns)"
  type        = bool
  default     = true
}

variable "allow_asg_management" {
  description = "will grant this policy the permission to update asg (specified in asg_arns)"
  type        = bool
  default     = true
}

variable "create_policy" {
  description = "actually create the policy, otherwise just render the policy"
  type        = bool
  default     = true
}


data "aws_caller_identity" "current" {}

locals {
  accountId = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "manage" {
  // readonly
  statement {
    actions = [
      "autoscaling:Describe*",
      "cloudwatch:Describe*",
      "cloudwatch:List*",
      "cloudwatch:Get*",
      "ec2:Describe*",
      "ec2:Get*",
      "elasticloadbalancing:Describe*",
      "eks:List*",
      "eks:Describe*",
      "iam:GetPolicy*",
      "iam:GetRole*",
      "iam:ListRole*",
      "iam:ListPolic*",
      "logs:Describe*",
      "logs:List*",
      "logs:Filter*",
      "logs:StartQuery",
      "logs:StopQuery",
      "route53:Get*",
      "route53:List*",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "nodegroup" {
  // Nodegroup
  statement {
    actions = [
      "eks:UpdateNodegroupConfig",
      "eks:UpdateNodegroupVersion",
    ]

    resources = var.nodegroup_arns
  }

}

data "aws_iam_policy_document" "asg" {
  // ASG
  statement {
    actions = [
      "autoscaling:CancelInstanceRefresh",
      "autoscaling:PutScalingPolicy",
      "autoscaling:ResumeProcesses",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:StartInstanceRefresh",
      "autoscaling:SuspendProcesses",
      "autoscaling:UpdateAutoScalingGroup"
    ]

    resources = var.asg_arns
  }
}

locals {
  nodegroup_management = var.allow_nodegroup_management ? [data.aws_iam_policy_document.nodegroup.json] : []
  asg_management       = var.allow_asg_management ? [data.aws_iam_policy_document.asg.json] : []
  policies             = concat([data.aws_iam_policy_document.manage.json], local.nodegroup_management, local.asg_management)
}

module "policy_agg" {
  source  = "cloudposse/iam-policy-document-aggregator/aws"
  version = "0.6.0"

  source_documents = local.policies
}

resource "aws_iam_policy" "policy" {
  name  = var.policy_name
  count = var.create_policy ? 1 : 0

  policy = module.policy_agg.result_document
}


output "policy_name" {
  value       = join("", aws_iam_policy.policy.*.name)
  description = "the name of the policy"
}

output "policy_arn" {
  value       = join("", aws_iam_policy.policy.*.arn)
  description = "the arn of the policy"
}

output "policy_document" {
  value       = data.aws_iam_policy_document.manage.json
  description = "the policy document"
}

