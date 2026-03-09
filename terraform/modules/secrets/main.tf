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

resource "random_password" "realtime_secret_key_base" {
  length  = 64
  special = false
}

resource "random_password" "meta_crypto_key" {
  length  = 32
  special = false
}

resource "random_password" "analytics_key" {
  length  = 64
  special = false
}

resource "random_password" "db_enc_key" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "supabase" {
  name = "${var.project_name}/supabase"

  tags = {
    Name    = "${var.project_name}/supabase"
    Project = var.project_name
  }
}

# Note on JWT keys: Supabase anon_key and service_role_key must be valid JWTs
# signed by the jwt_secret. In production, generate these using:
#   jwt.encode({"role": "anon", "iss": "supabase", "iat": ..., "exp": ...}, jwt_secret, "HS256")
#   jwt.encode({"role": "service_role", "iss": "supabase", "iat": ..., "exp": ...}, jwt_secret, "HS256")
# Then store them manually in Secrets Manager, or use a null_resource + local-exec provisioner.
# The placeholder values below must be replaced before deployment.

resource "aws_secretsmanager_secret_version" "supabase" {
  secret_id = aws_secretsmanager_secret.supabase.id

  secret_string = jsonencode({
    # Database
    db_username = var.db_username
    db_password = random_password.db_password.result
    db_name     = var.db_name

    # JWT — MUST be replaced with signed JWTs before deployment (see note above)
    jwt_secret       = random_password.jwt_secret.result
    anon_key         = "REPLACE_WITH_SIGNED_JWT_FOR_ANON_ROLE"
    service_role_key = "REPLACE_WITH_SIGNED_JWT_FOR_SERVICE_ROLE"

    # Dashboard
    dashboard_username = "supabase"
    dashboard_password = random_password.dashboard_password.result
    openai_api_key     = ""

    # Analytics (Logflare)
    analytics_public_token  = random_password.analytics_key.result
    analytics_private_token = random_password.analytics_key.result

    # S3 — placeholder values; prefer IRSA for S3 access (no static creds needed)
    s3_key_id    = "use-irsa-instead"
    s3_access_key = "use-irsa-instead"

    # Realtime
    realtime_secret_key_base = random_password.realtime_secret_key_base.result

    # Meta
    meta_crypto_key = random_password.meta_crypto_key.result

    # Realtime DB encryption
    db_enc_key = random_password.db_enc_key.result
  })
}
