variable "project_id" {
  description = "GCP project ID where SDP pipeline infrastructure is created."
  type        = string
}

variable "region" {
  description = "Default GCP region for Artifact Registry and Cloud Run."
  type        = string
  default     = "us-central1"
}

variable "dlp_location" {
  description = "Location for DLP templates (use 'global' or a region)."
  type        = string
  default     = "global"
}

variable "dataset_id" {
  description = "BigQuery dataset ID for sample/test tables."
  type        = string
  default     = "sdp_test"
}

variable "dataset_location" {
  description = "BigQuery dataset location."
  type        = string
  default     = "US"
}

variable "job_name" {
  description = "Cloud Run Job name for the masking pipeline."
  type        = string
  default     = "sdp-bq-masker"
}

variable "service_account_id" {
  description = "Service account ID (not email) used by the Cloud Run Job."
  type        = string
  default     = "sdp-bq-masker"
}

variable "artifact_registry_repo" {
  description = "Artifact Registry repository ID for pipeline images."
  type        = string
  default     = "sdp-pipeline"
}

variable "image" {
  description = "Container image for the Cloud Run Job. Defaults to the Artifact Registry :latest image."
  type        = string
  default     = null
}

variable "batch_size" {
  description = "Default BATCH_SIZE env for the Cloud Run Job."
  type        = number
  default     = 1000
}

variable "dlp_chunk_size" {
  description = "Default DLP_CHUNK_SIZE env for the Cloud Run Job."
  type        = number
  default     = 5000
}
