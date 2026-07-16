#!/usr/bin/env bash
# DEPRECATED: Prefer Terraform for infrastructure setup:
#   cd terraform && cp terraform.tfvars.example terraform.tfvars && terraform init && terraform apply
# This script is retained as a temporary non-Terraform fallback.
set -euo pipefail

echo "WARNING: scripts/setup_iam.sh is deprecated; use terraform/ instead." >&2

PROJECT_ID="${PROJECT_ID:?Set PROJECT_ID}"
REGION="${REGION:-us-central1}"
SA_NAME="${SA_NAME:-sdp-bq-masker}"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud services enable \
  dlp.googleapis.com \
  bigquery.googleapis.com \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  --project="${PROJECT_ID}"

if ! gcloud iam service-accounts describe "${SA_EMAIL}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud iam service-accounts create "${SA_NAME}" \
    --project="${PROJECT_ID}" \
    --display-name="SDP BigQuery PII masker"
fi

for ROLE in roles/dlp.user roles/bigquery.dataViewer roles/bigquery.dataEditor roles/bigquery.jobUser; do
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="${ROLE}" \
    --condition=None \
    --quiet
done

if ! gcloud artifacts repositories describe sdp-pipeline \
  --location="${REGION}" \
  --project="${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud artifacts repositories create sdp-pipeline \
    --repository-format=docker \
    --location="${REGION}" \
    --project="${PROJECT_ID}" \
    --description="SDP BigQuery masking pipeline images"
fi

cat <<EOF
IAM setup complete.

SERVICE_ACCOUNT=${SA_EMAIL}
REGION=${REGION}
IMAGE=${REGION}-docker.pkg.dev/${PROJECT_ID}/sdp-pipeline/sdp-bq-masker:latest
EOF