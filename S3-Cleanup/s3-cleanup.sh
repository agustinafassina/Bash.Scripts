#!/bin/bash
# v1.0 - S3 Cleanup: Delete objects older than X days (manual lifecycle)

# ============ CONFIGURATION ============
BUCKET=""                    # Your S3 bucket name (e.g. my-backups-bucket)
PREFIX=""                    # Optional: limit to prefix (e.g. backups/ or logs/)
DAYS_OLD=30                  # Delete objects older than this many days

# ============ SCRIPT ============
# Parse arguments
EXECUTE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute) EXECUTE=true; shift ;;
    *) break ;;
  esac
done
[ -n "$1" ] && BUCKET="$1"
[ -n "$2" ] && PREFIX="$2"
[ -n "$3" ] && DAYS_OLD="$3"

if [ -z "$BUCKET" ]; then
  echo "Error: BUCKET is required. Edit the script or pass as argument."
  echo ""
  echo "Usage: $0 [--execute] <bucket> [prefix] [days]"
  echo "  --execute  Actually delete (default is dry-run preview)"
  echo "  bucket    S3 bucket name"
  echo "  prefix    Optional prefix/folder (e.g. backups/)"
  echo "  days      Delete objects older than N days (default: $DAYS_OLD)"
  echo ""
  echo "Examples:"
  echo "  $0 my-bucket                    # Dry-run, whole bucket, 30 days"
  echo "  $0 my-bucket backups/ 7         # Dry-run, backups/ prefix, 7 days"
  echo "  $0 --execute my-bucket logs/ 90 # Actually delete"
  exit 1
fi

# Check dependencies
if ! command -v aws &>/dev/null; then
  echo "Error: AWS CLI is required."
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required for batch delete. Install: apt-get install jq / brew install jq"
  exit 1
fi

# Get cutoff date (GNU date - Linux / macOS BSD)
if date -d "@0" &>/dev/null 2>&1; then
  CUTOFF_EPOCH=$(date -d "$DAYS_OLD days ago" +%s 2>/dev/null)
else
  CUTOFF_EPOCH=$(date -v-${DAYS_OLD}d +%s 2>/dev/null)
fi

if [ -z "$CUTOFF_EPOCH" ]; then
  echo "Error: Could not calculate cutoff date."
  exit 1
fi

echo "=========================================="
echo "  S3 Cleanup 🗑️  - $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="
echo "  Bucket:  s3://$BUCKET/$PREFIX"
echo "  Delete:  Objects older than $DAYS_OLD days"
echo "  Mode:    $([ "$EXECUTE" = true ] && echo 'EXECUTE (will delete)' || echo 'DRY-RUN (preview only)')"
echo "=========================================="

# List objects (aws s3 ls format: 2024-01-15 10:30:00    12345 path/to/key)
KEYS_TO_DELETE=()
if [ -n "$PREFIX" ]; then
  LS_CMD="aws s3 ls s3://$BUCKET/$PREFIX --recursive"
else
  LS_CMD="aws s3 ls s3://$BUCKET/ --recursive"
fi

while IFS= read -r line; do
  [ -z "$line" ] && continue
  DATE_STR=$(echo "$line" | awk '{print $1, $2}')
  KEY=$(echo "$line" | awk '{$1=$2=$3=""; print $0}' | sed 's/^[[:space:]]*//')

  OBJ_EPOCH=$(date -d "$DATE_STR" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$DATE_STR" +%s 2>/dev/null)
  if [ -n "$OBJ_EPOCH" ] && [ "$OBJ_EPOCH" -lt "$CUTOFF_EPOCH" ]; then
    KEYS_TO_DELETE+=("$KEY")
  fi
done < <($LS_CMD 2>/dev/null)

COUNT=${#KEYS_TO_DELETE[@]}

if [ $COUNT -eq 0 ]; then
  echo "  No objects found older than $DAYS_OLD days."
  exit 0
fi

echo "  Found $COUNT object(s) to delete."
echo ""

# Delete in batches of 1000 (S3 limit)
BATCH_SIZE=1000
DELETED=0

for ((i=0; i<COUNT; i+=BATCH_SIZE)); do
  BATCH=("${KEYS_TO_DELETE[@]:i:BATCH_SIZE}")
  if [ "$EXECUTE" = true ]; then
    OBJECTS=$(printf '%s\n' "${BATCH[@]}" | jq -R -s -c 'split("\n") | map(select(length>0) | {Key: .}) | {Objects: ., Quiet: true}')
    aws s3api delete-objects --bucket "$BUCKET" --delete "$OBJECTS" >/dev/null 2>&1
    DELETED=$((DELETED + ${#BATCH[@]}))
    echo "  Deleted ${#BATCH[@]} object(s)..."
  else
    for key in "${BATCH[@]}"; do
      echo "  [DRY-RUN] Would delete: $key"
    done
  fi
done

echo ""
echo "=========================================="
if [ "$EXECUTE" = true ]; then
  echo "  Done. Deleted $DELETED object(s) ✓"
else
  echo "  Dry-run complete. Run with --execute to delete."
fi
echo "=========================================="
