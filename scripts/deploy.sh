#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TF_DIR="${PROJECT_DIR}/terraform"
K8S_DIR="${PROJECT_DIR}/kubernetes"

echo "============================================"
echo "  Supabase on AWS - Deployment Script"
echo "============================================"

# ── Phase 1: Terraform ──
echo ""
echo "==> Phase 1: Deploying infrastructure with Terraform..."
cd "$TF_DIR"

terraform init
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
rm -f tfplan

# Capture outputs
CLUSTER_NAME=$(terraform output -raw cluster_name)
AWS_REGION=$(terraform output -raw 2>/dev/null || echo "us-east-1")
ESO_ROLE_ARN=$(terraform output -raw eso_role_arn)
STORAGE_ROLE_ARN=$(terraform output -raw storage_role_arn)

echo "  Cluster: ${CLUSTER_NAME}"
echo "  Region:  ${AWS_REGION}"

# ── Phase 2: Configure kubectl ──
echo ""
echo "==> Phase 2: Configuring kubectl..."
aws eks update-kubeconfig \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}"

kubectl cluster-info

# ── Phase 3: Install External Secrets Operator ──
echo ""
echo "==> Phase 3: Installing External Secrets Operator..."
helm repo add external-secrets https://charts.external-secrets.io 2>/dev/null || true
helm repo update

helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --create-namespace \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${ESO_ROLE_ARN}" \
  --wait

# ── Phase 4: Apply K8s manifests ──
echo ""
echo "==> Phase 4: Applying Kubernetes manifests..."
kubectl apply -f "${K8S_DIR}/manifests/namespace.yaml"
kubectl apply -f "${K8S_DIR}/manifests/external-secrets/"
kubectl apply -f "${K8S_DIR}/manifests/network-policies/"
kubectl apply -f "${K8S_DIR}/manifests/karpenter/"

# Wait for ExternalSecret to sync
echo "  Waiting for secrets to sync..."
kubectl wait --for=condition=Ready externalsecret/supabase-secrets \
  -n supabase --timeout=120s 2>/dev/null || echo "  Warning: ExternalSecret sync timed out"

# ── Phase 5: Install Supabase via Helm ──
echo ""
echo "==> Phase 5: Installing Supabase via Helm..."
helm repo add supabase-community https://supabase-community.github.io/supabase-kubernetes 2>/dev/null || true

# Update storage IRSA annotation in values
helm upgrade --install supabase supabase-community/supabase \
  -f "${K8S_DIR}/values/supabase-production.yaml" \
  --namespace supabase \
  --set "serviceAccount.storage.annotations.eks\\.amazonaws\\.com/role-arn=${STORAGE_ROLE_ARN}" \
  --wait --timeout 10m

# ── Phase 6: Smoke test ──
echo ""
echo "==> Phase 6: Running smoke tests..."
bash "${SCRIPT_DIR}/smoke-test.sh"

echo ""
echo "============================================"
echo "  Deployment complete!"
echo "============================================"
