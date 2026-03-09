resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "random_password" "jwt_secret" {
  length  = 64
  special = false
}

resource "random_password" "dashboard_password" {
  length  = 24
  special = true
}

resource "random_password" "anon_key" {
  length  = 64
  special = false
}

resource "random_password" "service_role_key" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "supabase" {
  name = "${var.project_name}/supabase"

  tags = {
    Name    = "${var.project_name}/supabase"
    Project = var.project_name
  }
}

resource "aws_secretsmanager_secret_version" "supabase" {
  secret_id = aws_secretsmanager_secret.supabase.id

  secret_string = jsonencode({
    db_username      = var.db_username
    db_password      = random_password.db_password.result
    jwt_secret       = random_password.jwt_secret.result
    dashboard_password = random_password.dashboard_password.result
    anon_key         = random_password.anon_key.result
    service_role_key = random_password.service_role_key.result
  })
}
