terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws",
            version = "~> 4.41"
        }
    }

    required_version = ">= 1.0.0"

    backend "s3" {
        bucket = "autodoc-terraform"
        key = "example-net6/terraform.tfstate"
        region = "us-east-1"
        shared_credentials_file = "~/.aws/credentials"
        profile = "terraform-homolog"
    }    
}

provider "aws" {
    region = var.region
    profile = var.profile
}
