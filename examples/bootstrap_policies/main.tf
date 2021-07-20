provider "aws" {
  region = "us-east-1"
}

module "boostrap_default" {
  source      = "../../modules/bootstrap_policy"
  policy_name = "streamnative-mc-bootstrap-default"
}

module "boostrap_full" {
  source      = "../../modules/bootstrap_policy"
  policy_name = "streamnative-mc-bootstrap-full"

  allow_eks_management = true
  allow_iam_management = true
}

# useful if you just want to render the policy and directly apply to another role
module "bootstrap_full_render_only" {
  source      = "../../modules/bootstrap_policy"
  policy_name = "streamnative-mc-bootstrap-full"

  allow_eks_management = true
  allow_iam_management = true

  create_policy = false
}
