variable "project_name" {
  description = "Project name used for secret naming"
  type        = string
  default     = "stack-ai-supabase"
}

variable "db_username" {
  description = "Database master username to store in the secret"
  type        = string
  default     = "supabase_admin"
}
