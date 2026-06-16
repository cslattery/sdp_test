# SDP BigQuery Freetext PII Masking Pipeline

Test pipeline that reads freetext columns from BigQuery, masks PII with Google Sensitive Data Protection (SDP/DLP) templates, and writes to a new BigQuery table.

## Prerequisites

- `gcloud` CLI authenticated
- Billing enabled on your GCP project

## Setup

```bash
export PROJECT_ID=your-project-id
export REGION=us-central1
export DLP_LOCATION=global

chmod +x scripts/*.sh
./scripts/setup_iam.sh
./scripts/create_templates.sh
```

Save the `INSPECT_TEMPLATE` and `DEIDENTIFY_TEMPLATE` values from the template script output.

## Create test data

```bash
bq mk --dataset --location=US "${PROJECT_ID}:sdp_test"
# Edit PROJECT_ID in sql/test_data.sql, then:
bq query --use_legacy_sql=false < sql/test_data.sql
```

## Deploy

```bash
gcloud builds submit --config cloudbuild.yaml --project="${PROJECT_ID}"
```

Configure the job environment on first run:

```bash
export SOURCE_TABLE="${PROJECT_ID}.sdp_test.test_notes"
export TARGET_TABLE="${PROJECT_ID}.sdp_test.test_notes_masked"
export FREETEXT_COLUMNS=notes
export INSPECT_TEMPLATE=projects/.../inspectTemplates/...
export DEIDENTIFY_TEMPLATE=projects/.../deidentifyTemplates/...

./scripts/run_job.sh
```

Dry-run (first batch only, no writes):

```bash
DRY_RUN=true ./scripts/run_job.sh
```

## Validate

Edit `sql/validate.sql` with your project/dataset names, then:

```bash
bq query --use_legacy_sql=false < sql/validate.sql
```

## Local run

```bash
pip install -r requirements.txt
cd pipeline
export PROJECT_ID=... SOURCE_TABLE=... TARGET_TABLE=... FREETEXT_COLUMNS=notes \
  INSPECT_TEMPLATE=... DEIDENTIFY_TEMPLATE=...
python main.py
```