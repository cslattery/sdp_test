#!/usr/bin/env bash
# DEPRECATED: Prefer Terraform for DLP templates:
#   cd terraform && terraform apply
#   terraform output -raw inspect_template
#   terraform output -raw deidentify_template
# This script always POSTs new templates (not idempotent). Retained as a fallback.
set -euo pipefail

echo "WARNING: scripts/create_templates.sh is deprecated; use terraform/ instead." >&2

PROJECT_ID="${PROJECT_ID:?Set PROJECT_ID}"
DLP_LOCATION="${DLP_LOCATION:-global}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

INSPECT_RESPONSE="$(curl -sS -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -H "X-Goog-User-Project: ${PROJECT_ID}" \
  --data-binary "@${ROOT_DIR}/templates/inspect_template.json" \
  "https://dlp.googleapis.com/v2/projects/${PROJECT_ID}/locations/${DLP_LOCATION}/inspectTemplates")"

DEID_RESPONSE="$(curl -sS -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -H "X-Goog-User-Project: ${PROJECT_ID}" \
  --data-binary "@${ROOT_DIR}/templates/deidentify_template.json" \
  "https://dlp.googleapis.com/v2/projects/${PROJECT_ID}/locations/${DLP_LOCATION}/deidentifyTemplates")"

INSPECT_TEMPLATE_NAME="$(echo "${INSPECT_RESPONSE}" | python3 -c "import json,sys; print(json.load(sys.stdin)['name'])")"
DEIDENTIFY_TEMPLATE_NAME="$(echo "${DEID_RESPONSE}" | python3 -c "import json,sys; print(json.load(sys.stdin)['name'])")"

cat <<EOF
Created SDP templates in location: ${DLP_LOCATION}

INSPECT_TEMPLATE=${INSPECT_TEMPLATE_NAME}
DEIDENTIFY_TEMPLATE=${DEIDENTIFY_TEMPLATE_NAME}
EOF