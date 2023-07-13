terraform {
  cloud {
    organization = "infodsm"
    hostname     = "app.terraform.io" # default

    workspaces {
      name = "deploy-script"
    }
  }
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "aws" {
  access_key = var.TFC_AWS_ACCESS__KEY
  secret_key = var.TFC_AWS_SECRET_ACCESS_KEY
  region     = var.aws_region
}

provider "random" {
}
