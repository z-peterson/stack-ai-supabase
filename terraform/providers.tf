provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "stack-ai-supabase"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
