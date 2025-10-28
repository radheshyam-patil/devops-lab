#==============================================================================
# IAM MODULE - Input Variables
# 
# Variables needed to create IAM resources with proper naming and ARNs
#==============================================================================

#------------------------------------------------------------------------------
# ENVIRONMENT NAME
# Why: Used in role names and resource tags
#------------------------------------------------------------------------------
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

#------------------------------------------------------------------------------
# AWS REGION
# Why: Needed for constructing ARNs (Amazon Resource Names)
# Example: arn:aws:ecs:ap-south-1:123456789:service/...
#------------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
}

#------------------------------------------------------------------------------
# AWS ACCOUNT ID
# Why: Needed for constructing ARNs
# Example: Your account ID is 338658064058
#------------------------------------------------------------------------------
variable "account_id" {
  description = "AWS account ID"
  type        = string
}
