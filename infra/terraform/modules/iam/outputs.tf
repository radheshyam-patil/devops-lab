#==============================================================================
# IAM MODULE - Outputs
# 
# Export IAM role ARNs so ECS and Lambda can use them
#==============================================================================

#------------------------------------------------------------------------------
# ECS EXECUTION ROLE ARN
# Used by: ECS task definition (Phase 6)
#------------------------------------------------------------------------------
output "ecs_execution_role_arn" {
  description = "ARN of ECS execution role"
  value       = aws_iam_role.ecs_execution_role.arn
}

#------------------------------------------------------------------------------
# ECS TASK ROLE ARN
# Used by: ECS task definition (Phase 6)
#------------------------------------------------------------------------------
output "ecs_task_role_arn" {
  description = "ARN of ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

#------------------------------------------------------------------------------
# LAMBDA SCALE ROLE ARN
# Used by: Lambda function (Phase 6)
#------------------------------------------------------------------------------
output "lambda_scale_role_arn" {
  description = "ARN of Lambda scale role"
  value       = aws_iam_role.lambda_scale_role.arn
}
