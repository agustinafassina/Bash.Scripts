#!/bin/bash
# Generates an Amazon Inspector v2 findings report and exports it to S3.
# Requires: destination bucket, prefix and KMS key ARN (same region as Inspector).
# Docs: https://docs.aws.amazon.com/inspector/latest/user/findings-managing-exporting-reports.html

set -euo pipefail

# ============ CONFIGURATION (edit here or use flags) ============
AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-}}"
S3_BUCKET=""
S3_PREFIX="inspector-reports/"
KMS_KEY_ARN=""
REPORT_FORMAT="CSV" # CSV | JSON
FILTER_FILE=""
SEVERITIES=""       # e.g. CRITICAL,HIGH (optional; merged with --filter-file)
DOWNLOAD_DIR=""     # if set, downloads the report when it finishes
TIMESTAMP_PREFIX=true
WAIT_COMPLETION=true
MAX_WAIT_SEC=600
POLL_SEC=5
AWS_PROFILE_ARG=()

usage() {
  cat <<EOF
Uso: $0 [opciones]

Genera un reporte de hallazgos (Inspector v2) y lo deja en S3 vía create-findings-report.

Opciones:
  --bucket NAME         Bucket S3 de destino (obligatorio)
  --prefix PATH         Prefijo base en el bucket (default: $S3_PREFIX)
  --kms-arn ARN         ARN de la clave KMS para cifrado en S3 (obligatorio)
  --format FORMAT       CSV o JSON (default: $REPORT_FORMAT)
  --region REGION       Región de AWS
  --filter-file PATH    JSON con filter-criteria (ver filters-example.json)
  --severity LIST      Severidades: CRITICAL,HIGH,MEDIUM,LOW,INFORMATIONAL,UNTRIAGED
  --download DIR        Tras SUCCEEDED, descarga el/los archivos del reporte a DIR
  --no-timestamp        No añadir fecha/hora al prefijo S3 (por defecto sí se añade)
  --no-wait             No esperar; solo muestra reportId
  --max-wait SEC        Tiempo máximo de espera (default: $MAX_WAIT_SEC)
  --profile NAME        Perfil de AWS CLI
  -h, --help            Esta ayuda

Ejemplo:
  $0 --bucket mi-bucket --kms-arn arn:aws:kms:us-east-1:123:key/xxx \\
     --region us-east-1 --severity CRITICAL,HIGH --download ./out

Notas:
  - Inspector v2 debe estar habilitado en la región.
  - Bucket y KMS en la misma región; políticas deben permitir a Inspector escribir.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bucket)         S3_BUCKET="$2"; shift 2 ;;
    --prefix)         S3_PREFIX="$2"; shift 2 ;;
    --kms-arn)        KMS_KEY_ARN="$2"; shift 2 ;;
    --format)         REPORT_FORMAT="$2"; shift 2 ;;
    --region)         AWS_REGION="$2"; shift 2 ;;
    --filter-file)    FILTER_FILE="$2"; shift 2 ;;
    --severity)      SEVERITIES="$2"; shift 2 ;;
    --download)       DOWNLOAD_DIR="$2"; shift 2 ;;
    --no-timestamp)   TIMESTAMP_PREFIX=false; shift ;;
    --no-wait)        WAIT_COMPLETION=false; shift ;;
    --max-wait)       MAX_WAIT_SEC="$2"; shift 2 ;;
    --profile)        AWS_PROFILE_ARG=(--profile "$2"); shift 2 ;;
    -h|--help)        usage; exit 0 ;;
    *)
      echo "Opción desconocida: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

die() { echo "Error: $*" >&2; exit 1; }

if ! command -v aws &>/dev/null; then
  die "se requiere AWS CLI."
fi
if ! command -v jq &>/dev/null; then
  die "se requiere jq."
fi

[[ -n "$S3_BUCKET" && -n "$KMS_KEY_ARN" ]] || {
  usage >&2
  die "--bucket y --kms-arn son obligatorios."
}

RF_UPPER=$(echo "$REPORT_FORMAT" | tr '[:lower:]' '[:upper:]')
[[ "$RF_UPPER" == "CSV" || "$RF_UPPER" == "JSON" ]] || die "--format debe ser CSV o JSON."
REPORT_FORMAT="$RF_UPPER"

AWS_ARGS=()
[[ -n "$AWS_REGION" ]] && AWS_ARGS+=(--region "$AWS_REGION")
AWS_ARGS+=("${AWS_PROFILE_ARG[@]}")

# Timestamped prefix so previous reports are not overwritten
if [[ "$TIMESTAMP_PREFIX" == true ]]; then
  TS=$(date '+%Y%m%d-%H%M%S')
  S3_PREFIX="${S3_PREFIX%/}/$TS/"
fi

# Build filter-criteria (file + severities)
FILTER_JSON="{}"
if [[ -n "$FILTER_FILE" ]]; then
  [[ -f "$FILTER_FILE" ]] || die "no existe el archivo de filtros: $FILTER_FILE"
  FILTER_JSON=$(jq -c . "$FILTER_FILE") || die "JSON inválido en $FILTER_FILE"
fi

if [[ -n "$SEVERITIES" ]]; then
  SEV_JSON=$(echo "$SEVERITIES" | tr ',' '\n' | sed '/^[[:space:]]*$/d' | tr '[:lower:]' '[:upper:]' | \
    jq -R -s -c 'split("\n") | map(select(length>0)) | map({comparison:"EQUALS", value:.})')
  FILTER_JSON=$(echo "$FILTER_JSON" | jq -c --argjson sev "$SEV_JSON" '.severity = ((.severity // []) + $sev)')
fi

FILTER_ARGS=()
if [[ "$FILTER_JSON" != "{}" ]]; then
  TMP_FILTER=$(mktemp)
  trap 'rm -f "$TMP_FILTER"' EXIT
  echo "$FILTER_JSON" >"$TMP_FILTER"
  FILTER_ARGS+=(--filter-criteria "file://$TMP_FILTER")
fi

echo "=========================================="
echo "  Amazon Inspector v2 — Reporte de hallazgos"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# Preflight: credentials
IDENTITY=$(aws sts get-caller-identity "${AWS_ARGS[@]}" --output json 2>/dev/null) || \
  die "no se pudo autenticar con AWS CLI (revisá profile/credenciales)."
ACCOUNT=$(echo "$IDENTITY" | jq -r '.Account')
CALLER=$(echo "$IDENTITY" | jq -r '.Arn')
echo "  Cuenta:   $ACCOUNT"
echo "  Caller:   $CALLER"
echo "  Región:   ${AWS_REGION:-<default CLI>}"
echo "  Bucket:   s3://$S3_BUCKET/$S3_PREFIX"
echo "  Formato:  $REPORT_FORMAT"
[[ -n "$SEVERITIES" ]] && echo "  Severity: $SEVERITIES"
[[ "$FILTER_JSON" != "{}" ]] && echo "  Filtros:  $(echo "$FILTER_JSON" | jq -c .)"
echo "=========================================="

# Soft warning if Inspector is not enabled (does not block)
if STATUS=$(aws inspector2 batch-get-account-status "${AWS_ARGS[@]}" --account-ids "$ACCOUNT" --output json 2>/dev/null); then
  STATE=$(echo "$STATUS" | jq -r '.accounts[0].state.status // empty')
  if [[ -n "$STATE" && "$STATE" != "ENABLED" ]]; then
    echo "Aviso: estado de Inspector en la cuenta: $STATE (esperado: ENABLED)" >&2
  fi
fi

S3_DEST="bucketName=$S3_BUCKET,keyPrefix=$S3_PREFIX,kmsKeyArn=$KMS_KEY_ARN"

CREATE_OUT=$(aws inspector2 create-findings-report \
  "${AWS_ARGS[@]}" \
  --report-format "$REPORT_FORMAT" \
  --s3-destination "$S3_DEST" \
  ${FILTER_ARGS[@]+"${FILTER_ARGS[@]}"} \
  --output json)

REPORT_ID=$(echo "$CREATE_OUT" | jq -r '.reportId // empty')
[[ -n "$REPORT_ID" ]] || {
  echo "$CREATE_OUT" | jq . >&2
  die "no se obtuvo reportId."
}

echo ""
echo "ReportId: $REPORT_ID"

download_report() {
  local dest="$1"
  local key
  local found=0
  mkdir -p "$dest"
  echo ""
  echo "Descargando objetos bajo s3://$S3_BUCKET/$S3_PREFIX → $dest"
  # Prefer keys containing the reportId; if none, sync the whole prefix
  while IFS= read -r key; do
    [[ -z "$key" || "$key" == "None" ]] && continue
    aws s3 cp "s3://$S3_BUCKET/$key" "$dest/" "${AWS_ARGS[@]}"
    found=1
  done < <(aws s3api list-objects-v2 \
    "${AWS_ARGS[@]}" \
    --bucket "$S3_BUCKET" \
    --prefix "$S3_PREFIX" \
    --query "Contents[?contains(Key, \`$REPORT_ID\`)].Key" \
    --output text 2>/dev/null | tr '\t' '\n')

  if [[ "$found" -eq 0 ]]; then
    aws s3 sync "s3://$S3_BUCKET/$S3_PREFIX" "$dest/" "${AWS_ARGS[@]}"
  fi
  echo "Archivos en $dest:"
  ls -la "$dest"
}

if [[ "$WAIT_COMPLETION" != true ]]; then
  echo "Estado: solicitud enviada (--no-wait). Consultá con:"
  echo "  aws inspector2 get-findings-report-status --report-id $REPORT_ID ${AWS_ARGS[*]}"
  exit 0
fi

echo "Esperando finalización (máx. ${MAX_WAIT_SEC}s)..."
ELAPSED=0
while [[ $ELAPSED -lt $MAX_WAIT_SEC ]]; do
  STATUS_JSON=$(aws inspector2 get-findings-report-status \
    "${AWS_ARGS[@]}" \
    --report-id "$REPORT_ID" \
    --output json)

  ST=$(echo "$STATUS_JSON" | jq -r '.status // empty')
  case "$ST" in
    SUCCEEDED)
      echo ""
      echo "Reporte generado correctamente."
      echo "$STATUS_JSON" | jq '{reportId, status, destination}'
      if [[ -n "$DOWNLOAD_DIR" ]]; then
        download_report "$DOWNLOAD_DIR"
      else
        echo "Ubicación S3: s3://$S3_BUCKET/$S3_PREFIX"
        echo "Para bajarlo: $0 ... --download ./out  (o aws s3 sync s3://$S3_BUCKET/$S3_PREFIX ./out)"
      fi
      exit 0
      ;;
    FAILED|CANCELLED)
      echo ""
      echo "El reporte terminó con estado: $ST" >&2
      echo "$STATUS_JSON" | jq '{status, errorCode, errorMessage}' >&2
      exit 1
      ;;
    IN_PROGRESS|"")
      sleep "$POLL_SEC"
      ELAPSED=$((ELAPSED + POLL_SEC))
      printf '.'
      ;;
    *)
      echo ""
      echo "Estado desconocido: $ST" >&2
      echo "$STATUS_JSON" | jq . >&2
      exit 1
      ;;
  esac
done

echo "" >&2
echo "Error: tiempo de espera agotado (${MAX_WAIT_SEC}s). Último estado:" >&2
aws inspector2 get-findings-report-status "${AWS_ARGS[@]}" --report-id "$REPORT_ID" --output json | jq . >&2
exit 1
