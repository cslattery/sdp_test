resource "google_service_account" "pipeline" {
  account_id   = var.service_account_id
  display_name = "SDP BigQuery PII masker"
  description  = "Runs the SDP BigQuery freetext masking Cloud Run Job"
  project      = var.project_id

  depends_on = [google_project_service.required]
}

# jobUser is project-scoped (required to run BigQuery jobs).
resource "google_project_iam_member" "pipeline_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.pipeline.email}"
}

# dlp.user: call inspect/deidentify APIs.
# dlp.reader: get inspect/deidentify templates (dlp.inspectTemplates.get, etc.).
resource "google_project_iam_member" "pipeline_dlp_user" {
  project = var.project_id
  role    = "roles/dlp.user"
  member  = "serviceAccount:${google_service_account.pipeline.email}"
}

resource "google_project_iam_member" "pipeline_dlp_reader" {
  project = var.project_id
  role    = "roles/dlp.reader"
  member  = "serviceAccount:${google_service_account.pipeline.email}"
}

# Data access is scoped to the sample dataset (least privilege vs project-wide editor/viewer).
resource "google_bigquery_dataset_iam_member" "pipeline_data_viewer" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.sdp_test.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.pipeline.email}"
}

resource "google_bigquery_dataset_iam_member" "pipeline_data_editor" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.sdp_test.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.pipeline.email}"
}
