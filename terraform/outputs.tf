# ──────────────────────────────────────────────
# VPC
# ──────────────────────────────────────────────

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# ──────────────────────────────────────────────
# EKS
# ──────────────────────────────────────────────

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority" {
  description = "EKS cluster CA certificate (base64)"
  value       = module.eks.cluster_certificate_authority
  sensitive   = true
}

# ──────────────────────────────────────────────
# RDS
# ──────────────────────────────────────────────

output "rds_endpoint" {
  description = "RDS instance endpoint (host:port)"
  value       = module.rds.endpoint
}

output "rds_address" {
  description = "RDS instance hostname"
  value       = module.rds.address
}

# ──────────────────────────────────────────────
# S3
# ──────────────────────────────────────────────

output "storage_bucket_id" {
  description = "S3 storage bucket name"
  value       = module.s3.bucket_id
}

output "storage_bucket_arn" {
  description = "S3 storage bucket ARN"
  value       = module.s3.bucket_arn
}

# ──────────────────────────────────────────────
# Secrets
# ──────────────────────────────────────────────

output "secrets_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = module.secrets.secret_arn
}

# ──────────────────────────────────────────────
# IAM (IRSA)
# ──────────────────────────────────────────────

output "eso_role_arn" {
  description = "IAM role ARN for External Secrets Operator"
  value       = module.iam.eso_role_arn
}

output "storage_role_arn" {
  description = "IAM role ARN for Supabase Storage (S3 access)"
  value       = module.iam.storage_role_arn
}

output "karpenter_role_arn" {
  description = "IAM role ARN for Karpenter autoscaler"
  value       = module.iam.karpenter_role_arn
}
