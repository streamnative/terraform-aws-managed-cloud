provider "aws" {
  region = "us-east-1"
}

module "manage_min" {
  source      = "../../modules/management_policy"
  policy_name = "streamnative-mc-manage-min"

  allow_asg_management       = false
  allow_nodegroup_management = false
}

module "manage_full" {
  source      = "../../modules/management_policy"
  policy_name = "streamnative-mc-manage-full"
}
