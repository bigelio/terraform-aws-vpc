
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "custom_bucket"
    key    = "tfstate_files/terraform.tfstate"
    region = "af-south-1"
  }
}

# Configure the AWS Provider

provider "aws" {
  region = "af-south-1"
}

# section for creating a VPC

resource "aws_vpc" "custom_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "custom-vpc"
  }
}
# Creating bucket for storing state 
resource "aws_s3_bucket" "custom_bucket" {
  bucket = "custom-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }
}
# creating EC2 instance

resource "aws_subnet" "custom_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "af-south-1"

  tags = {
    Name = "custom-subnet"
  }
}

resource "aws_network_interface" "custom-network-interface" {
  subnet_id   = aws_subnet.custom_subnet.id
  private_ips = ["172.16.10.101"]

  tags = {
    Name = "network_interface"
  }
}

resource "aws_instance" "custom_ec2_instance" {
  ami           = "ami-005e54dee72cc1d00" # 
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.custom_network_interface.id
    device_index         = 0
  }

}
