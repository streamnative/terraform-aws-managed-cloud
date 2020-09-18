provider "aws" {
  region = "us-east-1"
}

module "aws_vault" {
  source = "../../modules/vault_resources"
  prefix = "myorg-prod"
  resource_tags = {
    Enviroment : "Production"
  }
}
