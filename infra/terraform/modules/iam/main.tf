#==============================================================================
# IAM MODULE - Main Configuration
# 
# This file creates IAM (Identity and Access Management) resources:
# - Roles: What AWS services can assume permissions
# - Policies: What actions are allowed/denied
# 
# IAM Roles we create:
# 1. ECS Execution Role - For ECS to pull Docker images, read secrets
# 2. ECS Task Role - For application to access AWS services
# 3. Lambda Execution Role - For Lambda to scale ECS to zero
# 
# Why IAM is important:
# - Security: Least privilege access (only what's needed)
# - No hardcoded credentials in code
# - Auditable: CloudTrail logs all IAM actions
#==============================================================================

#------------------------------------------------------------------------------
# ECS TASK EXECUTION ROLE
# 
# What: Role that ECS uses to pull images and start tasks
# Why: ECS needs permissions to:
#   - Pull Docker images from ECR
#   - Write logs to CloudWatch
#   - Read secrets from Secrets Manager
# 
# Trust policy: Only ECS service can assume this role
# Used by: ECS Fargate service (Phase 6)
#------------------------------------------------------------------------------
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.environment}-ecs-execution-role"

  # Trust policy: Who can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-ecs-execution-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

#------------------------------------------------------------------------------
# ATTACH AWS MANAGED POLICY - ECS Task Execution
# 
# What: AWS-provided policy with common ECS execution permissions
# Why: Easier than writing custom policy, AWS maintains it
# Permissions included:
# - Pull images from ECR
# - Write logs to CloudWatch
# - Get authentication tokens
#------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#------------------------------------------------------------------------------
# CUSTOM POLICY - Secrets Manager Access
# 
# What: Custom policy to read secrets from Secrets Manager
# Why: Application needs to read database passwords, API keys
# Permissions:
# - Read secrets with specific prefix
# - Decrypt secrets using KMS
# 
# Security:
# - Only secrets with prefix "dev/*" are accessible
# - Follows least privilege principle
#------------------------------------------------------------------------------
resource "aws_iam_role_policy" "ecs_secrets_policy" {
  name = "${var.environment}-ecs-secrets-policy"
  role = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",  # Read secret value
          "kms:Decrypt"                      # Decrypt encrypted secrets
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:${var.environment}/*",
          "arn:aws:kms:${var.aws_region}:${var.account_id}:key/*"
        ]
      }
    ]
  })
}

#------------------------------------------------------------------------------
# ECS TASK ROLE
# 
# What: Role that the application itself uses
# Why: Application needs to:
#   - Write logs to CloudWatch
#   - Call other AWS services (S3, SES, etc.)
# 
# Difference from Execution Role:
# - Execution Role: Used by ECS to START the task
# - Task Role: Used by APPLICATION CODE itself
# 
# Example use:
# - Node.js app writes logs to CloudWatch
# - Node.js app uploads files to S3
# - Node.js app sends emails via SES
#------------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-ecs-task-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

#------------------------------------------------------------------------------
# TASK ROLE POLICY - CloudWatch Logs
# 
# What: Allows application to write logs
# Why: Centralized logging for debugging and monitoring
# Permissions:
# - Create log groups
# - Create log streams
# - Write log events
#------------------------------------------------------------------------------
resource "aws_iam_role_policy" "ecs_task_cloudwatch_policy" {
  name = "${var.environment}-ecs-task-cloudwatch-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/ecs/${var.environment}/*"
      }
    ]
  })
}

#------------------------------------------------------------------------------
# LAMBDA EXECUTION ROLE (for Scale-to-Zero Function)
# 
# What: Role for Lambda function to scale ECS to zero
# Why: Cost optimization - stop ECS tasks when not needed
# 
# Use case:
# - Dev environment: Lambda stops ECS tasks after business hours
# - Saves money: ~$50/month in dev environment
# - Lambda runs on schedule (EventBridge cron)
# 
# Permissions needed:
# - Update ECS service desired count
# - Describe ECS services
# - Write logs to CloudWatch
#------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_scale_role" {
  name = "${var.environment}-lambda-scale-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-lambda-scale-role"
    Environment = var.environment
    Purpose     = "Scale ECS to zero for cost optimization"
    ManagedBy   = "Terraform"
  }
}

#------------------------------------------------------------------------------
# LAMBDA POLICY - ECS Scaling
# 
# What: Allows Lambda to control ECS service
# Why: Lambda needs to update desired task count
# Permissions:
# - UpdateService: Change desired count to 0 or 1
# - DescribeServices: Check current state
# - Write logs: For debugging
#------------------------------------------------------------------------------
resource "aws_iam_role_policy" "lambda_scale_policy" {
  name = "${var.environment}-lambda-scale-policy"
  role = aws_iam_role.lambda_scale_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",      # Change desired task count
          "ecs:DescribeServices"    # Check service status
        ]
        Resource = "arn:aws:ecs:${var.aws_region}:${var.account_id}:service/${var.environment}-*/*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/lambda/*"
      }
    ]
  })
}
