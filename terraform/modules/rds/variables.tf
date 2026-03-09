variable "identifier" {
  description = "RDS instance identifier"
  type        = string
  default     = "supabase-db"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 50
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "supabase"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "supabase_admin"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance will be created"
  type        = string
}

variable "eks_security_group_id" {
  description = "Security group ID of the EKS nodes allowed to connect"
  type        = string
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "production"
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when destroying the instance"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled"
  type        = bool
  default     = true
}
