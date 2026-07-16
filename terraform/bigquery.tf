resource "google_bigquery_dataset" "sdp_test" {
  project     = var.project_id
  dataset_id  = var.dataset_id
  location    = var.dataset_location
  description = "Sample tables for SDP BigQuery freetext PII masking tests"

  labels = {
    purpose = "sdp-pipeline-test"
  }

  depends_on = [google_project_service.required]
}

# Seed jobs use a content-hash job_id so SQL changes re-run CREATE OR REPLACE.
# Completed jobs are immutable; destroy only removes them from state / job history.

resource "google_bigquery_job" "seed_test_notes" {
  project  = var.project_id
  location = var.dataset_location
  job_id   = "seed-test-notes-${substr(md5(local.seed_test_notes_sql), 0, 12)}"

  query {
    query          = local.seed_test_notes_sql
    use_legacy_sql = false
  }

  depends_on = [google_bigquery_dataset.sdp_test]
}

resource "google_bigquery_job" "seed_test_support_tickets" {
  project  = var.project_id
  location = var.dataset_location
  job_id   = "seed-test-support-tickets-${substr(md5(local.seed_test_support_tickets_sql), 0, 12)}"

  query {
    query          = local.seed_test_support_tickets_sql
    use_legacy_sql = false
  }

  depends_on = [google_bigquery_dataset.sdp_test]
}

resource "google_bigquery_job" "seed_test_mixed_pii" {
  project  = var.project_id
  location = var.dataset_location
  job_id   = "seed-test-mixed-pii-${substr(md5(local.seed_test_mixed_pii_sql), 0, 12)}"

  query {
    query          = local.seed_test_mixed_pii_sql
    use_legacy_sql = false
  }

  depends_on = [google_bigquery_dataset.sdp_test]
}
