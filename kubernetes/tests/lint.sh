#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VALUES_DIR="${SCRIPT_DIR}/../values"

echo "==> Helm lint (supabase-production)..."
helm lint -f "${VALUES_DIR}/supabase-production.yaml" supabase-community/supabase

echo "==> Helm template render..."
helm template supabase supabase-community/supabase \
  -f "${VALUES_DIR}/supabase-production.yaml" \
  --namespace supabase > /dev/null

echo "All Helm checks passed."
