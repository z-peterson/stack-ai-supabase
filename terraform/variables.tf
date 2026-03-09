# ──────────────────────────────────────────────
# General
# ──────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g. production, staging)"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "stack-ai-supabase"
}

# ──────────────────────────────────────────────
# VPC
# ──────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# ──────────────────────────────────────────────
# EKS
# ──────────────────────────────────────────────

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "supabase-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.large"]
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 6
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

# ──────────────────────────────────────────────
# RDS
# ──────────────────────────────────────────────

variable "rds_identifier" {
  description = "RDS instance identifier"
  type        = string
  default     = "supabase-db"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 50
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "supabase"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "supabase_admin"
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot on destroy"
  type        = bool
  default     = false
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

# ──────────────────────────────────────────────
# S3
# ──────────────────────────────────────────────

variable "storage_bucket_name" {
  description = "S3 bucket name for Supabase storage"
  type        = string
  default     = "stack-ai-supabase-storage"
}
