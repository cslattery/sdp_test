#!/usr/bin/env bash
set -euo pipefail

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