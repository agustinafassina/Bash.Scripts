#!/bin/bash
ENDPOINTS=(
  "https://httpbin.org/get"
  "https://api.github.com"
  # "https://your-api.com/health"
  # "https://your-app.com"
)

# Timeout in seconds
TIMEOUT=10

# Expected HTTP status (2xx = healthy)
SUCCESS_CODES="200|201|204"

# ============ SCRIPT ============
FAILED=0

# Use arguments if provided, otherwise use configured endpoints
if [ $# -gt 0 ]; then
  ENDPOINTS=("$@")
fi

echo "=========================================="
echo "  Health Check - $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

for url in "${ENDPOINTS[@]}"; do
  # Skip empty lines and comments
  [[ -z "$url" || "$url" =~ ^[[:space:]]*# ]] && continue

  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}|%{time_total}" --connect-timeout "$TIMEOUT" --max-time "$TIMEOUT" "$url" 2>/dev/null)

  HTTP_CODE=$(echo "$RESPONSE" | cut -d'|' -f1)
  TIME_TOTAL=$(echo "$RESPONSE" | cut -d'|' -f2 2>/dev/null || echo "N/A")

  if [[ "$HTTP_CODE" =~ ^($SUCCESS_CODES)$ ]]; then
    echo "✅ OK    | $HTTP_CODE | ${TIME_TOTAL}s | $url"
  else
    echo "❌ FAIL  | $HTTP_CODE | ${TIME_TOTAL}s | $url"
    FAILED=$((FAILED + 1))
  fi
done

echo "=========================================="
if [ $FAILED -eq 0 ]; then
  echo "  All services are healthy ✓"
  exit 0
else
  echo "  $FAILED service(s) failed ✗"
  exit 1
fi
