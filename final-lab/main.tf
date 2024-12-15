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

# Private Subnets for Database
resource "aws_subnet" "private_subnet1" {
  vpc_id            = "vpc-08fcbd2bedfbbddaa"
  cidr_block        = "192.169.32.0/19"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet 1"
  }
}

# Private Subnets for Database
resource "aws_subnet" "private_subnet2" {
  vpc_id            = "vpc-08fcbd2bedfbbddaa"
  cidr_block        = "192.169.64.0/19"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet 2"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS MySQL instance"
  vpc_id      = "vpc-08fcbd2bedfbbddaa"

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
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

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
