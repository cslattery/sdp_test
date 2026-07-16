# SDP BigQuery Freetext PII Masking Pipeline

Test pipeline that reads freetext columns from BigQuery, masks PII with Google Sensitive Data Protection (SDP/DLP) templates, and writes to a new BigQuery table.

## Prerequisites

- `gcloud` CLI authenticated with permission to manage the project
- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.5`
- Billing enabled on your GCP project

## Infrastructure (Terraform)

All durable GCP resources are managed under `terraform/`:

| Resource | Details |
|----------|---------|
| APIs | DLP, BigQuery, Cloud Run, Artifact Registry, Cloud Build, IAM |
| Service account | `sdp-bq-masker` with DLP user, BQ jobUser, dataset dataViewer/dataEditor |
| Artifact Registry | `sdp-pipeline` (Docker) |
| DLP templates | Inspect + deidentify (replace with infoType) |
| BigQuery | Dataset `sdp_test` + sample tables (seeded) |
| Cloud Run Job | `sdp-bq-masker` (definition owned by Terraform) |

```bash
export PROJECT_ID=your-project-id

cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set project_id

terraform init
terraform apply
```

Useful outputs:

```bash
terraform output
terraform output -raw inspect_template
terraform output -raw deidentify_template
terraform output -raw run_job_env   # shell exports for scripts/run_job.sh
```

### Sample tables for testing

Terraform seeds these tables in `${PROJECT_ID}.sdp_test` (synthetic PII only):

| Table | Freetext columns | Purpose |
|-------|------------------|---------|
| `test_notes` | `notes` | Simple single-column masking |
| `test_support_tickets` | `subject`, `body`, `internal_notes` | Multi-column masking |
| `test_mixed_pii` | `content` | Coverage across template infoTypes + null/empty |

Masked targets are **not** pre-created; the pipeline creates them on each full run, e.g.:

- `${PROJECT_ID}.sdp_test.test_notes_masked`
- `${PROJECT_ID}.sdp_test.test_support_tickets_masked`
- `${PROJECT_ID}.sdp_test.test_mixed_pii_masked`

Fallback (without Terraform): create the dataset, edit `PROJECT_ID` in `sql/test_data.sql`, then:

```bash
bq mk --dataset --location=US "${PROJECT_ID}:sdp_test"
bq query --use_legacy_sql=false < sql/test_data.sql
```

## Deploy the container image

Terraform creates the Cloud Run Job definition; Cloud Build builds/pushes the image and updates the job image only:

```bash
gcloud builds submit --config cloudbuild.yaml --project="${PROJECT_ID}"
```

First apply may create the job before an image exists. Build the image before the first execute.

## Run the job

Load env from Terraform, then execute:

```bash
eval "$(cd terraform && terraform output -raw run_job_env)"
./scripts/run_job.sh
```

Dry-run (first batch only, no writes):

```bash
DRY_RUN=true ./scripts/run_job.sh
```

Other sample tables:

```bash
# Multi-column
export SOURCE_TABLE="${PROJECT_ID}.sdp_test.test_support_tickets"
export TARGET_TABLE="${PROJECT_ID}.sdp_test.test_support_tickets_masked"
export FREETEXT_COLUMNS=subject,body,internal_notes
./scripts/run_job.sh

# Mixed PII coverage
export SOURCE_TABLE="${PROJECT_ID}.sdp_test.test_mixed_pii"
export TARGET_TABLE="${PROJECT_ID}.sdp_test.test_mixed_pii_masked"
export FREETEXT_COLUMNS=content
./scripts/run_job.sh
```

> **IAM note:** The pipeline service account has BigQuery data access on `sdp_test` only. For tables in other datasets, grant additional dataset IAM.

## Validate

Edit `sql/validate.sql` with your project id, then:

```bash
bq query --use_legacy_sql=false < sql/validate.sql
```

## Local run

```bash
pip install -r requirements.txt
cd pipeline
eval "$(cd ../terraform && terraform output -raw run_job_env)"
python main.py
```

## Deprecated scripts

These shell helpers are replaced by Terraform and kept only as a temporary fallback:

- `scripts/setup_iam.sh` — APIs, SA, IAM, Artifact Registry
- `scripts/create_templates.sh` — DLP templates (non-idempotent POST)

## Layout

```
terraform/           # Infrastructure as code
  sql/               # Templated BigQuery seed queries
pipeline/            # Python masking job
templates/           # Reference DLP JSON (mirrored in terraform/dlp.tf)
sql/                 # Fallback seeds + validation queries
scripts/run_job.sh   # Execute Cloud Run Job with env overrides
cloudbuild.yaml      # Build/push image + image-only job update
```
