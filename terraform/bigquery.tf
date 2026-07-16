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

# Seed via query jobs with destination_table (not DDL).
# CREATE OR REPLACE fails when the provider sets create_disposition on the job.
# Content-hash job_ids re-seed when the SQL files change.

resource "google_bigquery_job" "seed_test_notes" {
  project  = var.project_id
  location = var.dataset_location
  job_id   = "seed-test-notes-${substr(md5(local.seed_test_notes_sql), 0, 12)}"

  query {
    query              = local.seed_test_notes_sql
    use_legacy_sql     = false
    create_disposition = "CREATE_IF_NEEDED"
    write_disposition  = "WRITE_TRUNCATE"

    destination_table {
      project_id = var.project_id
      dataset_id = google_bigquery_dataset.sdp_test.dataset_id
      table_id   = "test_notes"
    }
  }

  depends_on = [google_bigquery_dataset.sdp_test]
}

resource "google_bigquery_job" "seed_test_support_tickets" {
  project  = var.project_id
  location = var.dataset_location
  job_id   = "seed-test-support-tickets-${substr(md5(local.seed_test_support_tickets_sql), 0, 12)}"

  query {
    query              = local.seed_test_support_tickets_sql
    use_legacy_sql     = false
    create_disposition = "CREATE_IF_NEEDED"
    write_disposition  = "WRITE_TRUNCATE"

    destination_table {
      project_id = var.project_id
      dataset_id = google_bigquery_dataset.sdp_test.dataset_id
      table_id   = "test_support_tickets"
    }
  }

  depends_on = [google_bigquery_dataset.sdp_test]
}

resource "google_bigquery_job" "seed_test_mixed_pii" {
  project  = var.project_id
  location = var.dataset_location
  job_id   = "seed-test-mixed-pii-${substr(md5(local.seed_test_mixed_pii_sql), 0, 12)}"

  query {
    query              = local.seed_test_mixed_pii_sql
    use_legacy_sql     = false
    create_disposition = "CREATE_IF_NEEDED"
    write_disposition  = "WRITE_TRUNCATE"

    destination_table {
      project_id = var.project_id
      dataset_id = google_bigquery_dataset.sdp_test.dataset_id
      table_id   = "test_mixed_pii"
    }
  }

  depends_on = [google_bigquery_dataset.sdp_test]
}
