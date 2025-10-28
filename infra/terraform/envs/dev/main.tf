#==============================================================================
# DEV ENVIRONMENT - Main Configuration
# 
# This is the ROOT Terraform configuration that:
# 1. Configures Terraform backend (S3 + DynamoDB)
# 2. Configures AWS provider
# 3. Calls network module to create VPC, subnets, security groups
# 4. Calls IAM module to create roles and policies
# 
# Think of this as the "main()" function that orchestrates everything.
#==============================================================================

#------------------------------------------------------------------------------
# TERRAFORM CONFIGURATION
# 
# What: Terraform settings and required providers
# Why: Ensures everyone uses compatible Terraform versions
#------------------------------------------------------------------------------
terraform {
  # Backend configuration loaded from backend-config.hcl
  # This tells Terraform to store state in S3 (not locally)
  backend "s3" {
    # Configuration provided via: terraform init -backend-config=backend-config.hcl
    # bucket         = "devops-lab-tfstate-1761635567"
    # key            = "envs/dev/terraform.tfstate"
    # region         = "ap-south-1"
    # dynamodb_table = "devops-lab-tf-lock"
    # encrypt        = true
  }

  # Minimum Terraform version
  required_version = ">= 1.5.0"

  # Required providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use AWS provider version 5.x
    }
  }
}

#------------------------------------------------------------------------------
# AWS PROVIDER CONFIGURATION
# 
# What: Configures how Terraform talks to AWS
# Why: Sets region and default tags for all resources
# 
# Default tags applied to ALL resources:
# - Environment: dev
# - Project: devops-lab
# - ManagedBy: Terraform
# - Owner: DevOps-Team
#------------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region

  # Default tags applied to ALL resources
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Team"
      Repository  = "https://github.com/radheshyam-patil/devops-lab"
    }
  }
}

#------------------------------------------------------------------------------
# DATA SOURCE - AWS Account Information
# 
# What: Gets current AWS account ID and caller identity
# Why: Needed by IAM module to construct ARNs
# Returns: Account ID, User ID, ARN
#------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

#------------------------------------------------------------------------------
# NETWORK MODULE
# 
# What: Creates complete network infrastructure
# Resources created:
# - 1 VPC
# - 9 Subnets (3 public + 3 private + 3 database)
# - 1 Internet Gateway
# - 1 NAT Gateway
# - Route tables and associations
# - 3 Security Groups (ALB, ECS, RDS)
# 
# Why: Foundation for all other infrastructure
# Outputs: VPC ID, subnet IDs, security group IDs
#------------------------------------------------------------------------------
module "network" {
  source = "../../modules/network"

  environment        = var.environment
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  enable_nat_gateway = true # Set to false in dev to save money
}

#------------------------------------------------------------------------------
# IAM MODULE
# 
# What: Creates IAM roles and policies
# Resources created:
# - ECS Execution Role (pull images, read secrets)
# - ECS Task Role (application permissions)
# - Lambda Scale Role (scale to zero)
# 
# Why: Secure access to AWS services without hardcoded credentials
# Outputs: Role ARNs for use by ECS and Lambda
#------------------------------------------------------------------------------
module "iam" {
  source = "../../modules/iam"

  environment = var.environment
  aws_region  = var.aws_region
  account_id  = data.aws_caller_identity.current.account_id
}
