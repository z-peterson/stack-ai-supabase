#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Terraform init..."
terraform init -backend=false

echo "==> Terraform validate..."
terraform validate

echo "==> TFLint..."
tflint --init
tflint --recursive

echo "All Terraform checks passed."
