provider "aws" {
  region = "us-east-1"
}

module "boostrap_default" {
  source = "../../modules/bootstrap_policy"
  policy_name = "streamnative-mc-bootstrap-default"
}

module "boostrap_full" {
  source = "../../modules/bootstrap_policy"
  policy_name = "streamnative-mc-bootstrap-full"

  allow_eks_management = true
  allow_iam_management = true
}
