#==============================================================================
# DEV ENVIRONMENT - Variable Values
# 
# This file contains the ACTUAL values for variables.
# Different from variables.tf which only DEFINES the variables.
# 
# File format: HCL (HashiCorp Configuration Language)
# Syntax: variable_name = "value"
#==============================================================================

#------------------------------------------------------------------------------
# ENVIRONMENT CONFIGURATION
#------------------------------------------------------------------------------

# AWS region where all resources will be created
aws_region = "ap-south-1"

# Environment name (used in resource naming and tagging)
environment = "dev"

# Project name (used in tags)
project_name = "devops-lab"

#------------------------------------------------------------------------------
# NOTES FOR FUTURE CUSTOMIZATION
# 
# You can override these values by:
# 1. Creating terraform.tfvars (this file)
# 2. Using -var flag: terraform apply -var="environment=staging"
# 3. Using environment variables: TF_VAR_environment=staging
#------------------------------------------------------------------------------
