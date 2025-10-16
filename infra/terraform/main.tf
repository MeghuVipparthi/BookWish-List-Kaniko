
terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "azs" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"
  name = "${var.project_name}-vpc"
  cidr = "10.20.0.0/16"
  azs = slice(data.aws_availability_zones.azs.names,0,3)
  public_subnets  = ["10.20.1.0/24","10.20.2.0/24","10.20.3.0/24"]
  private_subnets = ["10.20.11.0/24","10.20.12.0/24","10.20.13.0/24"]
  enable_nat_gateway = true
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.0.0"

  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    ng_default = {
      desired_capacity = var.node_desired_count
      min_capacity     = var.node_min_count
      max_capacity     = var.node_max_count
      instance_types   = var.node_instance_types
    }
  }

  tags = { Project = var.project_name }
}

resource "aws_ecr_repository" "book_api" { name = "${var.project_name}-book-api" }
resource "aws_ecr_repository" "user_service" { name = "${var.project_name}-user-service" }
resource "aws_ecr_repository" "frontend" { name = "${var.project_name}-frontend" }

resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.project_name}-dbsub"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = var.db_allocated_storage
  engine               = "postgres"
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
  skip_final_snapshot  = true
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  publicly_accessible = false
}
