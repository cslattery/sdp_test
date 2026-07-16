resource "google_artifact_registry_repository" "pipeline" {
  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_registry_repo
  description   = "SDP BigQuery masking pipeline images"
  format        = "DOCKER"

  depends_on = [google_project_service.required]
}
