#==============================================================================
# NETWORK MODULE - Input Variables
# 
# This file defines all the parameters that can be passed to the network module.
# Think of these as function parameters in programming.
# 
# Variable types explained:
# - string: Text value (e.g., "dev", "prod")
# - list(string): Array of text values
# - bool: true or false
# - number: Numeric value
#==============================================================================

#------------------------------------------------------------------------------
# ENVIRONMENT NAME
# 
# What: Name of the environment (dev, staging, prod)
# Why: Used to prefix all resource names for organization
# Example: "dev-vpc", "prod-vpc"
# Required: Yes (no default value)
#------------------------------------------------------------------------------
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

#------------------------------------------------------------------------------
# VPC CIDR BLOCK
# 
# What: IP address range for the entire VPC
# Why: Defines how many IP addresses we have available
# Default: 10.0.0.0/16 (gives us 65,536 IP addresses)
# 
# CIDR explained:
# - 10.0.0.0/16 = 10.0.0.0 to 10.0.255.255
# - First 16 bits are network, last 16 bits are hosts
# - /16 = 65,536 addresses
# - /24 = 256 addresses
# - /32 = 1 address
#------------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for VPC (IP address range)"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

#------------------------------------------------------------------------------
# AVAILABILITY ZONES
# 
# What: List of AWS availability zones to use
# Why: High availability - if one AZ fails, others keep running
# Default: All 3 AZs in ap-south-1 (Mumbai)
# 
# What's an Availability Zone?
# - Separate data centers within a region
# - Independent power, networking, cooling
# - Located miles apart (disaster recovery)
# - Low latency between AZs in same region
#------------------------------------------------------------------------------
variable "availability_zones" {
  description = "List of availability zones for multi-AZ deployment"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Must specify at least 2 availability zones for HA."
  }
}

#------------------------------------------------------------------------------
# ENABLE NAT GATEWAY
# 
# What: Whether to create NAT Gateway or not
# Why: Cost optimization - can disable in dev to save money
# Default: true (enabled)
# 
# NAT Gateway cost:
# - ~$32/month per NAT Gateway
# - Plus data transfer charges
# - Dev: Can disable to save money (no internet for private subnets)
# - Prod: Should always be enabled
#------------------------------------------------------------------------------
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}
