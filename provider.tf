terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}


terraform {
  backend "s3" {
    bucket  = "state-locking-git-kandasamy"
    key     = "workspace.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}