terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "aws_ebs_burst_credits_exhausted" {
  source    = "./modules/aws_ebs_burst_credits_exhausted"

  providers = {
    shoreline = shoreline
  }
}