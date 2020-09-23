/**
 * # Bootstrap Policy
 *
 * This terraform module creates an IAM policy that contains
 * all of the permissions needed to bootstrap the underlying AWS resources
 * needed for a StreamNative cluster, but is *not* used to provision or manage
 * the cluster itself, see the Management policy for details on that policy.
 *
 * NOTE: this policy is not currently as constrained as it can be, we will continue
 * to reduce the needed permissions. Additionally, this is based of eksctl permissions
 * which we will slowly reduce
 *
 * This policy primarily includes the ability to:
 * * manage many ec2, cloudformation, eks, and IAM permissions
 * * create/delete/update dynamodb tables
 * * create/delete/update S3 buckets
 * * create/delete/update KMS keys and aliases
 *
 * These permissions can optionally be constrainted (where applicable)
 * by allowing it only to manage a prefix of resources (for s3 buckets, dynamodb tables)
 *
 * This policy is not intended for usage
 * with the administration/provisioning of the actual StreamNative cluster,
 * where we use a much more constrained policy, this is just for bootsrapping
 *
 * You can simply create this policy and attach to any role *or* use the `bootstrap_role` module
 * which creates the role with the needed permissions for streamnative to assume the role.
 *
 * Example:
 * ```
 * module "bootstrap_policy" {
 *   source = "streamnative/managed-cloud/aws//bootstrap_policy"
 *   policy_name = "streamnative-bootstrap-policy"
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

data "aws_caller_identity" "current" {}

locals {
  accountId = data.aws_caller_identity.current.account_id
}


data "aws_iam_policy_document" "provision" {
  // EKS
  statement {
    actions = [
      "eks:*",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "iam:PassRole",
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["eks.amazonaws.com"]
    }
  }

  // S3 Bucket Perms
  statement {
    actions = [
      "s3:CreateBucket",
      "s3:GetBucketLocation",
      "s3:GetBucket*",
      "s3:PutBucket*"
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_prefix}*"
    ]
  }

  statement {
    actions = [
      "s3:ListAllMyBuckets",
    ]

    resources = [
      "*"
    ]
  }

  // Dynamodb
  statement {
    actions = [
      "dynamodb:CreateTable*",
      "dynamodb:Describe*",
      "dynamodb:UpdateTable*",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:CreateBackup",
      "dynamodb:DeleteBackup",
      "dynamodb:RestoreTable*",
      "dynamodb:*ContinuousBackups",

    ]

    resources = [
      "arn:aws:dynamodb:${var.allowed_regions}:${local.accountId}:table/${var.dynamo_table_prefix}*"
    ]
  }

  statement {
    actions = [
      "dynamodb:CreateGlobalTable",
      "dynamodb:DescribeGlobal*",
      "dynamodb:UpdateGlobal*",
    ]

    resources = [
      "arn:aws:dynamodb:${var.allowed_regions}:${local.accountId}:global-table/${var.dynamo_table_prefix}*"
    ]
  }

  statement {
    actions = [
      "dynamodb:ListTables",
      "dynamodb:ListGlobalTables",
      "dynamodb:ListBackups",
    ]

    resources = [
      "arn:aws:dynamodb:${var.allowed_regions}:${local.accountId}:*"
    ]
  }

  // KMS
  statement {
    actions = [
      "kms:CreateKey",
      "kms:ListKeys",
      "kms:ListAliases",
      "kms:TagResource"
    ]

    resources = ["arn:aws:kms:${var.allowed_regions}:${local.accountId}:*"]
  }

  statement {
    actions = [
      "kms:CreateAlias",
    ]

    resources = ["arn:aws:kms:${var.allowed_regions}:${local.accountId}:alias/${var.kms_alias_prefix}*"]
  }

  // EC2 (for usage with eksctl)
  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DeleteSubnet",
      "ec2:DeleteTags",
      "ec2:CreateNatGateway",
      "ec2:CreateVpc",
      "ec2:AttachInternetGateway",
      "ec2:DescribeVpcAttribute",
      "ec2:DeleteRouteTable",
      "ec2:AssociateRouteTable",
      "ec2:DescribeInternetGateways",
      "ec2:CreateRoute",
      "ec2:CreateInternetGateway",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateSecurityGroup",
      "ec2:ModifyVpcAttribute",
      "ec2:DeleteInternetGateway",
      "ec2:DescribeRouteTables",
      "ec2:ReleaseAddress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:DescribeTags",
      "ec2:CreateTags",
      "ec2:DeleteRoute",
      "ec2:CreateRouteTable",
      "ec2:DetachInternetGateway",
      "ec2:DescribeNatGateways",
      "ec2:DisassociateRouteTable",
      "ec2:AllocateAddress",
      "ec2:DescribeSecurityGroups",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteNatGateway",
      "ec2:DeleteVpc",
      "ec2:CreateSubnet",
      "ec2:DescribeSubnets",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:describeAddresses",
      "ec2:DescribeVpcs",
      "ec2:CreateLaunchTemplate",
      "ec2:DescribeLaunchTemplates",
      "ec2:RunInstances",
      "ec2:DescribeLaunchTemplateVersions"
    ]

    resources = ["*"]

  }

  // Autoscaling (for usage with eksctl)
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:CreateLaunchConfiguration",
      "autoscaling:DeleteLaunchConfiguration",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:DeleteAutoScalingGroup",
      "autoscaling:CreateAutoScalingGroup"
    ]

    resources = ["*"]
  }

  // Cloudformation (for usgae with eksctl)
  statement {
    actions = [
      "cloudformation:*"
    ]

    resources = ["*"]
  }

  // IAM (for usage with eksctl)
  statement {
    actions = [
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetRole",
      "iam:GetInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
      "iam:ListInstanceProfiles",
      "iam:AddRoleToInstanceProfile",
      "iam:ListInstanceProfilesForRole",
      "iam:PassRole",
      "iam:DetachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:GetOpenIDConnectProvider"
    ]

    resources = [
      "arn:aws:iam::${local.accountId}:role/eksctl-*",
      "arn:aws:iam::${local.accountId}:instance-profile/eksctl-*",
    ]
  }

  // OIDC (for usage with eksctl)
  statement {
    actions = [
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider"
    ]
    resources = [
      "arn:aws:iam::${local.accountId}:oidc-provider/*"
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name = var.policy_name

  policy = data.aws_iam_policy_document.provision.json
}


output "policy_name" {
  value       = aws_iam_policy.policy.name
  description = "the name of the policy"
}

output "policy_arn" {
  value       = aws_iam_policy.policy.arn
  description = "the arn of the policy"
}

output "policy_document" {
  value       = data.aws_iam_policy_document.provision.json
  description = "the policy document"
}

