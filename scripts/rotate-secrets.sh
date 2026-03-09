#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TF_DIR="${PROJECT_DIR}/terraform"

echo "==> Secret Rotation - Supabase on AWS"
echo ""

# ── Phase 1: Rotate secrets in Terraform ──
echo "==> Phase 1: Regenerating secrets via Terraform..."
cd "$TF_DIR"

# Taint the random passwords to force regeneration
terraform taint module.secrets.random_password.jwt_secret
terraform taint module.secrets.random_password.dashboard_password
terraform taint module.secrets.random_password.anon_key
terraform taint module.secrets.random_password.service_role_key

# Apply to update Secrets Manager
terraform apply -var-file=terraform.tfvars -auto-approve \
  -target=module.secrets

echo ""

# ── Phase 2: Trigger ESO refresh ──
echo "==> Phase 2: Triggering External Secrets refresh..."
kubectl annotate externalsecret supabase-secrets \
  -n supabase \
  force-sync="$(date +%s)" \
  --overwrite

# Wait for sync
echo "  Waiting for secrets to sync..."
sleep 10

kubectl get externalsecret supabase-secrets -n supabase \
  -o jsonpath='{.status.conditions[0].message}'
echo ""

# ── Phase 3: Rolling restart ──
echo ""
echo "==> Phase 3: Rolling restart of Supabase services..."
for deploy in auth rest realtime storage kong studio meta functions vector imgproxy analytics; do
  kubectl rollout restart deployment "supabase-supabase-${deploy}" \
    -n supabase 2>/dev/null || echo "  Skipped ${deploy} (not found)"
done

echo ""
echo "==> Waiting for rollouts to complete..."
kubectl rollout status deployment -n supabase --timeout=5m 2>/dev/null || true

echo ""
echo "==> Secret rotation complete."
echo "Note: Database password was NOT rotated (requires RDS modification + connection string update)."
echo "To rotate the DB password, update it in RDS and re-run 'terraform apply'."
