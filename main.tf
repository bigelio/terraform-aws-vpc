
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "custom-bucket"
    key    = "tfstate_files/terraform.tfstate"
    region = "af-south-1"
  }
}

# Configure the AWS Provider

provider "aws" {
  region = "af-south-1"
}

# section for creating a VPC

resource "aws_vpc" "custom-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "custom-vpc"
  }
}
# Creating bucket for storing state 
resource "aws_s3_bucket" "custom-bucket" {
  bucket = "custom-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }
}
