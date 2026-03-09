output "eso_role_arn" {
  description = "IAM role ARN for the External Secrets Operator service account"
  value       = aws_iam_role.eso.arn
}

output "storage_role_arn" {
  description = "IAM role ARN for the Supabase Storage service account"
  value       = aws_iam_role.storage.arn
}

output "karpenter_role_arn" {
  description = "IAM role ARN for the Karpenter autoscaler service account"
  value       = aws_iam_role.karpenter.arn
}
