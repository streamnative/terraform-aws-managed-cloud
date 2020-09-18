# Currently, this top level module is primarily just an example of
# how to use these modules.

terraform {
  required_providers {
    aws = {
      version = ">= 2.70.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
}


module "role" {
  source           = "./modules/base_role"
  role_name        = "my-managed-cloud-role"
  role_policy_name = "default"
}


module "tiered_storage" {
  source      = "./modules/tiered_storage"
  bucket_name = "myorg-pulsar-offload-us-east-1"
  bucket_tags = {
    Project     = "MyApp"
    Environment = "Prod"
  }
  # attach policy to existing role
  existing_role_name = module.role.role_name
}

module "aws_vault" {
  source = "./modules/vault_resources"
  prefix = "myorg-prod"
  resource_tags = {
    Enviroment : "Production"
  }
  # attach policy to existing role
  existing_role_name = module.role.role_name
}
