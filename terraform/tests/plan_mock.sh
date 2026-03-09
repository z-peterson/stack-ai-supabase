#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Terraform init..."
terraform init -backend=false

echo "==> Terraform validate..."
terraform validate

echo "==> Terraform plan (mock values)..."
terraform plan -var-file=terraform.tfvars.example -input=false

echo "Mock plan completed."
