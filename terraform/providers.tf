# CẤU HÌNH TERRAFORM CORE VÀ PROVIDER
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# CẤU HÌNH PROVIDER AWS
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "NT542.Q11-Terraform"
      ManagedBy   = "Terraform"
      Owner       = var.owner_email
    }
  }
}
