provider "aws" {
}

module "aws_vault" {
  source = "../../provision/aws_vault_resources"
  prefix = "myorg-prod"
  resource_tags = {
    Enviroment: "Production"
  }
}
