# main.tf - Comprehensive Terraform Infrastructure Configuration

# Terraform Configuration Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Configure Remote State Backend (S3)
  backend "s3" {
    bucket = "titanium-devops-o1"
    key    = "terraform/state"
    region = "us-east-1"
  }
}

# Configure AWS Provider
provider "aws" {
  region = "us-east-1"
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

# Private Subnets for Database
resource "aws_subnet" "private_subnets" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = "us-east-1${count.index == 0 ? "a" : "b"}"

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS MySQL instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "private_subnet_group" {
  name       = "private-db-subnet-group"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name = "Private DB Subnet Group"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "mysql_database" {
  identifier        = "titanium-database"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.medium"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "myapplication"
  username = "admin"
  password = var.db_password # Set via environment variable or secret

  backup_retention_period = 7
  multi_az                = true

  db_subnet_group_name   = aws_db_subnet_group.private_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]


  skip_final_snapshot = true
}

# ECR Repository for Frontend
resource "aws_ecr_repository" "frontend" {
  name                 = "frontend-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECR Repository for Backend
resource "aws_ecr_repository" "backend" {
  name                 = "backend-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Variables
variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

# Outputs
output "rds_endpoint" {
  value       = aws_db_instance.mysql_database.endpoint
  description = "The connection endpoint for the RDS instance"
  sensitive   = true
}

output "frontend_repository_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "backend_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}
