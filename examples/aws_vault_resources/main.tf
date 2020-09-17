provider "aws" {
  region = "us-east-1"
}

module "aws_vault" {
  source = "../../provision/aws_vault_resources"
  prefix = "myorg-prod"
  resource_tags = {
    Enviroment : "Production"
  }
}
