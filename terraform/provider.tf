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
  region = var.aws_region
}

provider "random" {
}
