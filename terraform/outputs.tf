output "project_id" {
  description = "GCP project ID."
  value       = var.project_id
}

output "region" {
  description = "Primary region."
  value       = var.region
}

output "service_account_email" {
  description = "Pipeline service account email."
  value       = google_service_account.pipeline.email
}

output "inspect_template" {
  description = "DLP inspect template resource name (INSPECT_TEMPLATE)."
  value       = google_data_loss_prevention_inspect_template.freetext.name
}

output "deidentify_template" {
  description = "DLP deidentify template resource name (DEIDENTIFY_TEMPLATE)."
  value       = google_data_loss_prevention_deidentify_template.freetext.name
}

output "dataset_id" {
  description = "BigQuery dataset for sample tables."
  value       = google_bigquery_dataset.sdp_test.dataset_id
}

output "sample_tables" {
  description = "Fully qualified sample source table IDs."
  value       = local.sample_tables
}

output "default_source_table" {
  description = "Default SOURCE_TABLE wired into the Cloud Run Job."
  value       = local.default_source_table
}

output "default_target_table" {
  description = "Default TARGET_TABLE wired into the Cloud Run Job."
  value       = local.default_target_table
}

output "artifact_registry_repo" {
  description = "Artifact Registry repository resource name."
  value       = google_artifact_registry_repository.pipeline.name
}

output "image" {
  description = "Container image used by the Cloud Run Job (may be ignored after first Cloud Build)."
  value       = local.image
}

output "job_name" {
  description = "Cloud Run Job name."
  value       = google_cloud_run_v2_job.masker.name
}

output "run_job_env" {
  description = "Shell exports for scripts/run_job.sh against the default sample table."
  value       = <<-EOT
    export PROJECT_ID='${var.project_id}'
    export REGION='${var.region}'
    export JOB_NAME='${var.job_name}'
    export SOURCE_TABLE='${local.default_source_table}'
    export TARGET_TABLE='${local.default_target_table}'
    export FREETEXT_COLUMNS='notes'
    export INSPECT_TEMPLATE='${google_data_loss_prevention_inspect_template.freetext.name}'
    export DEIDENTIFY_TEMPLATE='${google_data_loss_prevention_deidentify_template.freetext.name}'
    export DLP_LOCATION='${var.dlp_location}'
  EOT
}
