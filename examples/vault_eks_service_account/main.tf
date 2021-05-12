terraform {
  required_version = "~> 0.13.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.7.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

variable "env" {
  description = "the name of the environment"
}

variable "eks_cluster_name" {
  description = "the name of the eks cluster"
}

variable "k8s_namespace" {
  description = "the namespace used in k8s for vault"
}

variable "company_name" {
  description = "a name to identitfy your organization or unit, like 'mycompany'"
}

data "aws_caller_identity" "current" {}

// reference the EKS cluster for o
data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

locals {
  accountId = data.aws_caller_identity.current.account_id
  issuerUrl = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

data "aws_iam_policy_document" "base_policy" {
  statement {
    actions = [
      "sts:GetCallerIdentity"
    ]

    resources = ["*"]
  }
}

module "vault_resources" {
  source  = "streamnative/managed-cloud/aws//modules/vault_resources"
  version = "0.3.1"

  prefix = "${var.company_name}-${var.env}-vault-"
}

// this role is used by vault and makes use of vault resources created above
module "vault_service_account" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "0.3.1"
  // the cloudposse modules do their own naming
  namespace   = var.company_name
  environment = var.env
  name        = "sn-vault"
  tags = {
    Env = "stg"
  }

  aws_account_number          = local.accountId
  eks_cluster_oidc_issuer_url = local.issuerUrl

  service_account_name      = "vault"
  service_account_namespace = var.k8s_namespace

  // attach a minimal policy here then attach a managed policy later
  aws_iam_policy_document = data.aws_iam_policy_document.base_policy.json
}

resource "aws_iam_role_policy_attachment" "vault" {
  role       = module.vault_service_account.service_account_role_name
  policy_arn = module.vault_resources.policy_arn
}

