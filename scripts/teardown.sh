#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TF_DIR="${PROJECT_DIR}/terraform"

echo "============================================"
echo "  Supabase on AWS - Teardown Script"
echo "============================================"
echo ""
echo "WARNING: This will destroy ALL infrastructure."
read -r -p "Type 'destroy' to confirm: " CONFIRM

if [ "$CONFIRM" != "destroy" ]; then
  echo "Aborted."
  exit 1
fi

# ── Phase 1: Remove Helm releases ──
echo ""
echo "==> Phase 1: Removing Helm releases..."
helm uninstall supabase --namespace supabase 2>/dev/null || echo "  Supabase already removed"
helm uninstall external-secrets --namespace external-secrets 2>/dev/null || echo "  ESO already removed"

# ── Phase 2: Remove K8s resources ──
echo ""
echo "==> Phase 2: Removing Kubernetes resources..."
kubectl delete namespace supabase --ignore-not-found
kubectl delete namespace external-secrets --ignore-not-found

# ── Phase 3: Terraform destroy ──
echo ""
echo "==> Phase 3: Destroying infrastructure with Terraform..."
cd "$TF_DIR"

# Disable deletion protection for RDS before destroy
terraform apply \
  -var-file=terraform.tfvars \
  -var="rds_deletion_protection=false" \
  -var="rds_skip_final_snapshot=true" \
  -target=module.rds \
  -auto-approve

terraform destroy -var-file=terraform.tfvars -auto-approve

echo ""
echo "============================================"
echo "  Teardown complete."
echo "============================================"
