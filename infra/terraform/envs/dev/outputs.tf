#==============================================================================
# DEV ENVIRONMENT - Outputs
# 
# These outputs are displayed after 'terraform apply'
# They're also stored in terraform.tfstate for reference
#==============================================================================

#------------------------------------------------------------------------------
# NETWORK OUTPUTS
# 
# What: VPC and subnet information
# Why: Needed when deploying application resources (Phase 6)
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs (for ALB)"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs (for ECS tasks)"
  value       = module.network.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Database subnet IDs (for RDS)"
  value       = module.network.database_subnet_ids
}

#------------------------------------------------------------------------------
# SECURITY GROUP OUTPUTS
# 
# What: Security group IDs
# Why: Required when creating ALB, ECS, RDS in later phases
#------------------------------------------------------------------------------
output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.network.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "ECS tasks security group ID"
  value       = module.network.ecs_tasks_security_group_id
}

output "rds_security_group_id" {
  description = "RDS database security group ID"
  value       = module.network.rds_security_group_id
}

#------------------------------------------------------------------------------
# IAM OUTPUTS
# 
# What: IAM role ARNs
# Why: Required when creating ECS task definitions and Lambda functions
#------------------------------------------------------------------------------
output "ecs_execution_role_arn" {
  description = "ECS execution role ARN"
  value       = module.iam.ecs_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ECS task role ARN"
  value       = module.iam.ecs_task_role_arn
}

output "lambda_scale_role_arn" {
  description = "Lambda scale role ARN"
  value       = module.iam.lambda_scale_role_arn
}

#------------------------------------------------------------------------------
# ENVIRONMENT INFO
# 
# What: Environment metadata
# Why: Quick reference for current deployment
#------------------------------------------------------------------------------
output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}
