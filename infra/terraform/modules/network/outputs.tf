#==============================================================================
# NETWORK MODULE - Outputs
# 
# This file exports values from this module so other modules can use them.
# Think of these as return values from a function.
# 
# Why we need outputs:
# - Other modules need to reference network resources
# - Example: ECS module needs to know which subnets to use
# - Example: RDS module needs to know security group IDs
#==============================================================================

#------------------------------------------------------------------------------
# VPC ID
# 
# What: Unique identifier for the VPC
# Why: Other resources need to know which VPC they belong to
# Used by: Security groups, subnets, route tables
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

#------------------------------------------------------------------------------
# VPC CIDR BLOCK
# 
# What: The IP address range of the VPC
# Why: Useful for network planning and security group rules
# Example: "10.0.0.0/16"
#------------------------------------------------------------------------------
output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

#------------------------------------------------------------------------------
# PUBLIC SUBNET IDS
# 
# What: List of public subnet IDs
# Why: ALB needs to know which subnets to deploy in
# Returns: ["subnet-xxx", "subnet-yyy", "subnet-zzz"]
# Used by: Application Load Balancer (Phase 6)
#------------------------------------------------------------------------------
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

#------------------------------------------------------------------------------
# PRIVATE SUBNET IDS
# 
# What: List of private subnet IDs
# Why: ECS tasks will run in these subnets
# Returns: ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
# Used by: ECS Fargate tasks (Phase 6)
#------------------------------------------------------------------------------
output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

#------------------------------------------------------------------------------
# DATABASE SUBNET IDS
# 
# What: List of database subnet IDs
# Why: RDS needs to know which subnets to deploy in
# Returns: ["subnet-ddd", "subnet-eee", "subnet-fff"]
# Used by: RDS PostgreSQL (Phase 5)
#------------------------------------------------------------------------------
output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = aws_subnet.database[*].id
}

#------------------------------------------------------------------------------
# ALB SECURITY GROUP ID
# 
# What: Security group ID for Application Load Balancer
# Why: ALB needs this to control incoming traffic
# Used by: Application Load Balancer (Phase 6)
#------------------------------------------------------------------------------
output "alb_security_group_id" {
  description = "Security group ID for Application Load Balancer"
  value       = aws_security_group.alb.id
}

#------------------------------------------------------------------------------
# ECS TASKS SECURITY GROUP ID
# 
# What: Security group ID for ECS Fargate tasks
# Why: ECS tasks need this for network access control
# Used by: ECS Fargate tasks (Phase 6)
#------------------------------------------------------------------------------
output "ecs_tasks_security_group_id" {
  description = "Security group ID for ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

#------------------------------------------------------------------------------
# RDS SECURITY GROUP ID
# 
# What: Security group ID for RDS database
# Why: RDS needs this to control database access
# Used by: RDS PostgreSQL (Phase 5)
#------------------------------------------------------------------------------
output "rds_security_group_id" {
  description = "Security group ID for RDS database"
  value       = aws_security_group.rds.id
}

#------------------------------------------------------------------------------
# NAT GATEWAY ID
# 
# What: NAT Gateway ID (if enabled)
# Why: Useful for monitoring and troubleshooting
# Returns: "nat-xxxxxxxx" or null (if disabled)
#------------------------------------------------------------------------------
output "nat_gateway_id" {
  description = "ID of the NAT Gateway (null if disabled)"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[0].id : null
}
