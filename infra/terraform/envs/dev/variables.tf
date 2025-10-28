#==============================================================================
# DEV ENVIRONMENT - Input Variables
# 
# These are the root-level variables that can be customized per environment.
# Actual values are set in terraform.tfvars
#==============================================================================

#------------------------------------------------------------------------------
# AWS REGION
# 
# What: AWS region to deploy resources
# Why: All resources will be created in this region
# Default: ap-south-1 (Mumbai)
# 
# Other common regions:
# - us-east-1 (Virginia)
# - us-west-2 (Oregon)
# - eu-west-1 (Ireland)
# - ap-southeast-1 (Singapore)
#------------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "ap-south-1"
}

#------------------------------------------------------------------------------
# ENVIRONMENT NAME
# 
# What: Name of this environment
# Why: Used to prefix all resource names
# Allowed values: dev, staging, prod
# Example: "dev-vpc", "dev-ecs-cluster"
#------------------------------------------------------------------------------
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

#------------------------------------------------------------------------------
# PROJECT NAME
# 
# What: Name of the project
# Why: Used in tags and resource naming
# Example: devops-lab
#------------------------------------------------------------------------------
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-lab"
}
