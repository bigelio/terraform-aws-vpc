
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

# AWS RDS

resource "aws_db_subnet_group" "custom_db_subnet" {
  name       = "custom_db_subnet"
  subnet_ids = ["10.0.4.0/24", "10.0.5.0/24"]
  tags = {
    Name = "custom db subnet"
  }
} 
resource "aws_db_parameter_group" "custom_db_parameter_group" {
  name   = "custom_db_parameter_group"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}  

resource "aws_db_instance" "custom_db_instance" {
  identifier             = "custom_db_instance"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "13.1"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.custom_db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.custom_db_parameter_group.name
  publicly_accessible    = false
  skip_final_snapshot    = true
}
