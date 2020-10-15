/**
 * # Bootstrap Policy
 *
 * This terraform module creates an IAM policy that contains
 * the permissions needed to bootstrap the underlying AWS resources
 * needed for a StreamNative cluster, but is *not* used to provision or manage
 * the cluster itself, see the Management policy for details on that policy.
 *
 * As different customers have different needs, this policy is configurable
 * with different levels of access being given based on the options
 *
 * The primary options are as follows, listed in order of increasing access:
 * - `allow_iam_policy_create`, this is needed for us to manage policies for resources created, but does not include the ability to actually attach those policies
 * - `allow_vault_management` (and `dynamo_table_prefix`, and `kms_alias_prefix`) allows for managing dynamo and kms key/alias (with optional prefix)
 * - `allow_tiered_storage_management` (and `s3_bucket_prefix`) allows for managing an s3 bucket with optional prefix
 * - `allow_eks_management`, this gives a broad set of permissions, including most of ec2, VPC and IAM, for managing EKS clusters and networks. IAM is namespced to `eksctl` roles
 * - `allow_iam_management`, gives access to create and attach iam roles and policies arbitrarily
 * - `allow_acm_certificate_management`, gives access to create ACM certificate and validate certificate through Route53
 *
 * NOTE: the `allow_eks_creation` is not currently as constrained as it can be, we will continue
 * to reduce the needed permissions.
 *
 * You can simply create this policy and attach to any role/user *or* use the `bootstrap_role` module
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

data "aws_iam_policy_document" "base_permissions" {
  statement {
    actions = [
      "ec2:DescribeAccountAttributes"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "iam_policy_create" {
  statement {
    actions = [
      "iam:GetPolicy*",
      "iam:CreatePolicy*",
      "iam:ListPolicies"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "vault" {
  // Dynamodb
  statement {
    actions = [
      "dynamodb:CreateTable*",
      "dynamodb:Describe*",
      "dynamodb:DeleteTable*",
      "dynamodb:UpdateTable*",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:ListTagsOfResource",
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
      "dynamodb:DeleteGlobalTable*",
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
      "kms:CreateAlias",
      "kms:CreateKey",
      "kms:DescribeKey",
      "kms:DeleteAlias",
      "kms:DeleteKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListKeys",
      "kms:ListAliases",
      "kms:ListResourceTags",
      "kms:ScheduleKeyDeletion",
      "kms:TagResource"
    ]

    resources = ["*"]
  }
}
data "aws_iam_policy_document" "tiered_storage" {
  // S3 Bucket Perms
  statement {
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutAccelerateConfiguration",
      "s3:PutAccessPointPolicy",
      "s3:PutAccountPublicAccessBlock",
      "s3:PutAnalyticsConfiguration",
      "s3:PutBucket*",
      "s3:PutEncryptionConfiguration",
      "s3:PutInventoryConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutMetricsConfiguration",
      "s3:PutReplicationConfiguration",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_prefix}*"
    ]
  }

  statement {
    actions = [
      "s3:GetAccelerateConfiguration",
      "s3:GetAccessPointPolicy",
      "s3:GetAccountPublicAccessBlock",
      "s3:GetAnalyticsConfiguration",
      "s3:GetBucket*",
      "s3:GetBucketLocation",
      "s3:GetEncryptionConfiguration",
      "s3:GetInventoryConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetMetricsConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
    ]

    resources = [
      "*"
    ]
  }

}
data "aws_iam_policy_document" "eks" {
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
      "iam:DeleteOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
    ]
    resources = [
      "arn:aws:iam::${local.accountId}:oidc-provider/*"
    ]
  }
}

data "aws_iam_policy_document" "iam_manager" {
  statement {
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:CreatePolicy*",
      "iam:CreateRole*",
      "iam:CreateServiceLinkedRole",
      "iam:DeleteInstanceProfile",
      "iam:DeletePolicy*",
      "iam:DeleteRole*",
      "iam:DeleteServiceLinkedRole",
      "iam:DetachRolePolicy",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:GetAccountAuthorizationDetails",
      "iam:GetAccountSummary",
      "iam:GetInstanceProfile",
      "iam:GetRole*",
      "iam:GetPolicy*",
      "iam:ListAttached*",
      "iam:ListEntitiesForPolicy",
      "iam:ListInstanceProfiles",
      "iam:ListInstanceProfilesForRole",
      "iam:ListPolicy*",
      "iam:ListRole*",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "acm_certificate" {
  // request certificate
  statement {
    actions = [
      "acm:AddTagsToCertificate",
      "acm:DeleteCertificate",
      "acm:DescribeCertificate",
      "acm:ExportCertificate",
      "acm:GetCertificate",
      "acm:ImportCertificate",
      "acm:ListCertificates",
      "acm:ListTagsForCertificate",
      "acm:RemoveTagsFromCertificate",
      "acm:RequestCertificate",
      "acm:ResendValidationEmail"
    ]

    resources = [
      "*"
    ]
  }

  // DNS validation
  statement {
    actions = [
      "route53:GetChange",
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]

    resources = [
      "arn:aws:route53:::hostedzone/*",
      "arn:aws:route53:::change/*"
    ]
  }

  statement {
    actions = [
      "route53:ListHostedZonesByName"
    ]

    resources = [
      "*"
    ]
  }
}

locals {
  policy_creator        = var.allow_iam_policy_create ? [data.aws_iam_policy_document.iam_policy_create.json] : []
  vault_manage          = var.allow_vault_management ? [data.aws_iam_policy_document.vault.json] : []
  tiered_storage_manage = var.allow_tiered_storage_management ? [data.aws_iam_policy_document.tiered_storage.json] : []
  eks_manage            = var.allow_eks_management ? [data.aws_iam_policy_document.eks.json] : []
  iam_manage            = var.allow_iam_management ? [data.aws_iam_policy_document.iam_manager.json] : []
  acm_cert_manage       = var.allow_acm_certificate_management ? [data.aws_iam_policy_document.acm_certificate.json] : []
  policies              = concat([data.aws_iam_policy_document.base_permissions.json], local.policy_creator, local.vault_manage, local.tiered_storage_manage, local.eks_manage, local.iam_manage, local.acm_cert_manage)
}

module "policy_agg" {
  source  = "cloudposse/iam-policy-document-aggregator/aws"
  version = "0.6.0"

  source_documents = local.policies
}

resource "aws_iam_policy" "policy" {
  name = var.policy_name

  policy = module.policy_agg.result_document
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
  value       = module.policy_agg.result_document
  description = "the policy document"
}

