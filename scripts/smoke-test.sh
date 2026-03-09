#!/usr/bin/env bash
set -euo pipefail

echo "==> Running Supabase smoke tests..."

# Get the Kong service endpoint
KONG_SVC=$(kubectl get svc -n supabase -l app.kubernetes.io/name=kong -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$KONG_SVC" ]; then
  echo "  Warning: Kong service not found. Using port-forward approach..."
  echo "  Run: kubectl port-forward -n supabase svc/supabase-kong 8000:8000"
  BASE_URL="http://localhost:8000"
else
  # Port-forward in background
  kubectl port-forward -n supabase "svc/${KONG_SVC}" 8000:8000 &
  PF_PID=$!
  trap 'kill $PF_PID 2>/dev/null' EXIT
  sleep 3
  BASE_URL="http://localhost:8000"
fi

PASS=0
FAIL=0

check_endpoint() {
  local name="$1"
  local path="$2"
  local expected_code="${3:-200}"

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}${path}" 2>/dev/null || echo "000")

  if [ "$HTTP_CODE" = "$expected_code" ]; then
    echo "  [PASS] ${name} (HTTP ${HTTP_CODE})"
    PASS=$((PASS + 1))
  else
    echo "  [FAIL] ${name} (HTTP ${HTTP_CODE}, expected ${expected_code})"
    FAIL=$((FAIL + 1))
  fi
}

# Health checks
check_endpoint "Kong API Gateway" "/" "200"
check_endpoint "GoTrue Auth" "/auth/v1/health" "200"
check_endpoint "PostgREST" "/rest/v1/" "200"
check_endpoint "Studio" "/studio" "200"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"

if [ "$FAIL" -gt 0 ]; then
  echo "Some smoke tests failed."
  exit 1
fi

echo "All smoke tests passed."
