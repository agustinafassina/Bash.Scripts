#!/bin/bash
# v1.0 - Log rotation: compress old logs and delete files past retention

# ============ CONFIGURATION ============
LOG_DIR="/var/log/myapp"     # Directory to process (non-recursive by default)
GLOB="*.log"                 # Filename pattern (quoted for find -name)
RECURSIVE=false              # true = include subdirectories

# Compress plain log files older than this many days (0 = skip compression)
COMPRESS_AFTER_DAYS=7

# Delete files matching DELETE_GLOB older than this many days
DELETE_AFTER_DAYS=30
DELETE_GLOB="*.log.gz"       # Safe default; use "*.log.*" or "*" only if you understand the risk

# ============ SCRIPT ============
EXECUTE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute) EXECUTE=true; shift ;;
    *) break ;;
  esac
done

[ -n "$1" ] && LOG_DIR="$1"
[ -n "$2" ] && DELETE_AFTER_DAYS="$2"
[ -n "$3" ] && COMPRESS_AFTER_DAYS="$3"

if [ -z "$LOG_DIR" ] || [ ! -d "$LOG_DIR" ]; then
  echo "Error: LOG_DIR must exist: $LOG_DIR"
  echo ""
  echo "Usage: $0 [--execute] [log_dir] [delete_after_days] [compress_after_days]"
  echo "  --execute           Apply changes (default: dry-run)"
  echo "  log_dir             Path to log directory (default: see script CONFIG)"
  echo "  delete_after_days   Delete files older than N days (default: $DELETE_AFTER_DAYS)"
  echo "  compress_after_days Compress *.log older than N days; 0 disables (default: $COMPRESS_AFTER_DAYS)"
  echo ""
  echo "Edit GLOB, DELETE_GLOB, RECURSIVE in the script for your layout."
  exit 1
fi

if ! command -v gzip &>/dev/null; then
  echo "Error: gzip is required."
  exit 1
fi

echo "=========================================="
echo "  Log rotation 📜 - $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="
echo "  Directory:   $LOG_DIR"
echo "  Compress:      *.log older than $COMPRESS_AFTER_DAYS days (if > 0)"
echo "  Delete:        $DELETE_GLOB older than $DELETE_AFTER_DAYS days"
echo "  Recursive:     $RECURSIVE"
echo "  Mode:          $([ "$EXECUTE" = true ] && echo 'EXECUTE' || echo 'DRY-RUN')"
echo "=========================================="

COMPRESSED=0
DELETED=0

# Build find depth
DEPTH_OPT=(-maxdepth 1)
[ "$RECURSIVE" = true ] && DEPTH_OPT=()

compress_one() {
  local f="$1"
  [ ! -f "$f" ] && return
  [[ "$f" == *.gz ]] && return
  if [ "$EXECUTE" = true ]; then
    gzip -9 -n "$f" && COMPRESSED=$((COMPRESSED + 1))
  else
    echo "  [DRY-RUN] Would gzip: $f"
    COMPRESSED=$((COMPRESSED + 1))
  fi
}

delete_one() {
  local f="$1"
  [ ! -e "$f" ] && return
  if [ "$EXECUTE" = true ]; then
    rm -f -- "$f" && DELETED=$((DELETED + 1))
  else
    echo "  [DRY-RUN] Would delete: $f"
    DELETED=$((DELETED + 1))
  fi
}

if [ "${COMPRESS_AFTER_DAYS:-0}" -gt 0 ]; then
  while IFS= read -r -d '' f; do
    compress_one "$f"
  done < <(find "$LOG_DIR" "${DEPTH_OPT[@]}" -type f -name "$GLOB" ! -name '*.gz' -mtime +"$COMPRESS_AFTER_DAYS" -print0 2>/dev/null)
fi

while IFS= read -r -d '' f; do
  delete_one "$f"
done < <(find "$LOG_DIR" "${DEPTH_OPT[@]}" -type f -name "$DELETE_GLOB" -mtime +"$DELETE_AFTER_DAYS" -print0 2>/dev/null)

echo ""
echo "=========================================="
if [ "$EXECUTE" = true ]; then
  echo "  Done. Compressed: $COMPRESSED | Deleted: $DELETED ✓"
else
  echo "  Dry-run. Would compress: $COMPRESSED | Would delete: $DELETED"
  echo "  Run with --execute to apply."
fi
echo "=========================================="
