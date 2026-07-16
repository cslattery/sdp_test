provider "google" {
  project = var.project_id
  region  = var.region

  # Required for user ADC (gcloud auth application-default login) against
  # APIs like DLP that need a quota project on the request.
  user_project_override = true
  billing_project       = var.project_id
}
