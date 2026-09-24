variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Use lowercase letters, numbers and hyphens only."
  }
}

variable "project_name" {
  description = "Project name."
  type        = string
  default     = "ha-three-tier"
}

variable "vpc_cidr" {
  description = "VPC CIDR."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrsubnet(var.vpc_cidr, 8, 31)) && can(regex("^.+/([0-9]|1[0-9]|20)$", var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR with a prefix of /20 or larger network, for example 10.0.0.0/16."
  }
}

variable "web_instance_type" {
  description = "Web EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "app_instance_type" {
  description = "Application EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "PostgreSQL master username."
  type        = string
  default     = "appadmin"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,62}$", var.db_username))
    error_message = "Username must start with a letter and contain only letters, numbers and underscores."
  }
}

variable "web_min_size" {
  type    = number
  default = 2
}

variable "web_desired_size" {
  type    = number
  default = 2
}

variable "web_max_size" {
  type    = number
  default = 4
}

variable "app_min_size" {
  type    = number
  default = 2
}

variable "app_desired_size" {
  type    = number
  default = 2
}

variable "app_max_size" {
  type    = number
  default = 4
}

variable "acm_certificate_arn" {
  description = "Optional ACM certificate ARN for public HTTPS."
  type        = string
  default     = null
  nullable    = true
}

variable "rds_backup_retention_days" {
  type    = number
  default = 7
}
