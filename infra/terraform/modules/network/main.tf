#==============================================================================
# NETWORK MODULE - Main Configuration
# 
# This file creates the complete network infrastructure:
# - VPC (Virtual Private Cloud)
# - 9 Subnets across 3 Availability Zones
# - Internet Gateway (for public internet access)
# - NAT Gateway (for private subnet outbound access)
# - Route Tables (traffic routing rules)
# - Security Groups (firewall rules)
#
# Why we need this:
# - Isolated network for our application
# - High availability across multiple AZs
# - Security through network segmentation
#==============================================================================

#------------------------------------------------------------------------------
# VPC - Virtual Private Cloud
# 
# What: An isolated virtual network in AWS
# Why: Provides network isolation and control
# CIDR: 10.0.0.0/16 gives us 65,536 IP addresses
#------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true  # Allows instances to get DNS names
  enable_dns_support   = true  # Enables DNS resolution

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

#------------------------------------------------------------------------------
# INTERNET GATEWAY
# 
# What: Gateway that allows VPC to communicate with the internet
# Why: Required for public subnets to access internet
# Used by: Public subnets (ALB, NAT Gateway)
#------------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

#------------------------------------------------------------------------------
# PUBLIC SUBNETS (3 - one per AZ)
# 
# What: Subnets with direct internet access via Internet Gateway
# Why: Host public-facing resources (ALB, NAT Gateway)
# CIDR: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24 (256 IPs each)
# 
# Resources that will run here:
# - Application Load Balancer (receives traffic from internet)
# - NAT Gateway (provides internet for private subnets)
#------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)  # Creates 3 subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true  # Auto-assign public IPs

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Public"
    AZ          = var.availability_zones[count.index]
  }
}

#------------------------------------------------------------------------------
# PRIVATE SUBNETS (3 - one per AZ)
# 
# What: Subnets with NO direct internet access
# Why: Enhanced security for application servers
# CIDR: 10.0.11.0/24, 10.0.12.0/24, 10.0.13.0/24
# 
# Resources that will run here:
# - ECS Fargate tasks (backend Node.js API)
# - ECS Fargate tasks (frontend React app)
# 
# Internet access: Via NAT Gateway (outbound only)
# - Can download npm packages
# - Can call external APIs
# - CANNOT be accessed directly from internet
#------------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)  # Creates 3 subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.environment}-private-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Private"
    AZ          = var.availability_zones[count.index]
  }
}

#------------------------------------------------------------------------------
# DATABASE SUBNETS (3 - one per AZ)
# 
# What: Dedicated subnets for database resources
# Why: Extra security layer, isolated from application
# CIDR: 10.0.21.0/24, 10.0.22.0/24, 10.0.23.0/24
# 
# Resources that will run here:
# - RDS PostgreSQL (primary database)
# - RDS read replicas (if we add them later)
# 
# Access: Only from private subnets (ECS tasks)
# NO internet access at all (maximum security)
#------------------------------------------------------------------------------
resource "aws_subnet" "database" {
  count             = length(var.availability_zones)  # Creates 3 subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.environment}-database-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Database"
    AZ          = var.availability_zones[count.index]
  }
}

#------------------------------------------------------------------------------
# ELASTIC IP FOR NAT GATEWAY
# 
# What: Static public IP address
# Why: NAT Gateway needs a fixed IP to route traffic
# Cost: FREE when attached to running NAT Gateway
#------------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"  # EIP for VPC (not EC2-Classic)

  tags = {
    Name        = "${var.environment}-nat-eip"
    Environment = var.environment
  }

  # Must create IGW before EIP
  depends_on = [aws_internet_gateway.main]
}

#------------------------------------------------------------------------------
# NAT GATEWAY
# 
# What: Allows private subnets to access internet (outbound only)
# Why: Private subnets need to download packages, call APIs
# Location: Lives in PUBLIC subnet, routes traffic to internet
# 
# Traffic flow:
# Private Subnet → NAT Gateway → Internet Gateway → Internet
# 
# Security: Only OUTBOUND traffic allowed
# - Private instances can initiate connections to internet
# - Internet CANNOT initiate connections to private instances
# 
# Cost optimization:
# - Creating only 1 NAT Gateway (not 3) to save money
# - Costs ~$32/month + data transfer
# - Production would have 3 (one per AZ for HA)
#------------------------------------------------------------------------------
resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id  # Must be in public subnet

  tags = {
    Name        = "${var.environment}-nat-gateway"
    Environment = var.environment
  }

  # Must create IGW before NAT Gateway
  depends_on = [aws_internet_gateway.main]
}

#------------------------------------------------------------------------------
# ROUTE TABLE FOR PUBLIC SUBNETS
# 
# What: Routing rules for public subnets
# Why: Defines how traffic exits the subnet
# 
# Route:
# Destination: 0.0.0.0/0 (all internet traffic)
# Target: Internet Gateway (direct internet access)
#------------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"              # All internet-bound traffic
    gateway_id = aws_internet_gateway.main.id  # Goes to Internet Gateway
  }

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
  }
}

#------------------------------------------------------------------------------
# ROUTE TABLE FOR PRIVATE SUBNETS
# 
# What: Routing rules for private subnets
# Why: Defines how traffic exits the subnet
# 
# Route:
# Destination: 0.0.0.0/0 (all internet traffic)
# Target: NAT Gateway (filtered internet access)
#------------------------------------------------------------------------------
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"                    # All internet-bound traffic
    nat_gateway_id = aws_nat_gateway.main[0].id  # Goes through NAT Gateway
  }

  tags = {
    Name        = "${var.environment}-private-rt"
    Environment = var.environment
  }
}

#------------------------------------------------------------------------------
# ROUTE TABLE ASSOCIATIONS - PUBLIC SUBNETS
# 
# What: Links public subnets to public route table
# Why: Without this, subnets don't know which route table to use
# Result: All 3 public subnets can access internet directly
#------------------------------------------------------------------------------
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#------------------------------------------------------------------------------
# ROUTE TABLE ASSOCIATIONS - PRIVATE SUBNETS
# 
# What: Links private subnets to private route table
# Why: Routes outbound traffic through NAT Gateway
# Result: Private subnets can access internet via NAT
#------------------------------------------------------------------------------
resource "aws_route_table_association" "private" {
  count          = var.enable_nat_gateway ? length(aws_subnet.private) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

#------------------------------------------------------------------------------
# SECURITY GROUP - APPLICATION LOAD BALANCER (ALB)
# 
# What: Firewall rules for Load Balancer
# Why: Controls what traffic can reach the ALB
# 
# Inbound Rules:
# - Port 80 (HTTP) from anywhere (0.0.0.0/0)
# - Port 443 (HTTPS) from anywhere (0.0.0.0/0)
# 
# Outbound Rules:
# - All traffic allowed (ALB needs to talk to ECS tasks)
# 
# Used by: Application Load Balancer (created in Phase 6)
#------------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name_prefix = "${var.environment}-alb-sg-"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # From anywhere
    description = "HTTP from internet"
  }

  # Allow HTTPS from internet
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # From anywhere
    description = "HTTPS from internet"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }

  # Create new SG before destroying old one (zero-downtime updates)
  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# SECURITY GROUP - ECS TASKS (Application Containers)
# 
# What: Firewall rules for ECS Fargate tasks
# Why: Controls what traffic can reach our application
# 
# Inbound Rules:
# - Port 8080 from ALB security group ONLY
# - NO direct internet access
# 
# Outbound Rules:
# - All traffic allowed (need to call database, external APIs)
# 
# Security benefit:
# - Only ALB can reach our application
# - Hackers cannot directly access our application
# - Defense in depth security model
#------------------------------------------------------------------------------
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "${var.environment}-ecs-tasks-sg-"
  description = "Security group for ECS Fargate tasks"
  vpc_id      = aws_vpc.main.id

  # Allow traffic from ALB only
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]  # Only from ALB
    description     = "Allow traffic from ALB on port 8080"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.environment}-ecs-tasks-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# SECURITY GROUP - RDS DATABASE
# 
# What: Firewall rules for PostgreSQL database
# Why: Maximum security for database access
# 
# Inbound Rules:
# - Port 5432 (PostgreSQL) from ECS security group ONLY
# - NO internet access
# - NO other access
# 
# Outbound Rules:
# - None (database doesn't initiate outbound connections)
# 
# Security benefit:
# - ONLY our application can access database
# - Even if ALB is compromised, database is still protected
# - Triple layer security: ALB → ECS → RDS
#------------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  name_prefix = "${var.environment}-rds-sg-"
  description = "Security group for RDS PostgreSQL database"
  vpc_id      = aws_vpc.main.id

  # Allow PostgreSQL from ECS tasks only
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]  # Only from ECS
    description     = "PostgreSQL from ECS tasks only"
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}
