#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MANIFESTS_DIR="${SCRIPT_DIR}/../manifests"

echo "==> Validating K8s manifests with kubeconform..."
find "${MANIFESTS_DIR}" -name '*.yaml' -print0 | \
  xargs -0 kubeconform -strict -ignore-missing-schemas -summary

echo "All K8s manifests are valid."
