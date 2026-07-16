terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.40.0, < 7.0.0"
    }
  }

  # Optional remote state example (uncomment and set bucket):
  # backend "gcs" {
  #   bucket = "YOUR_TF_STATE_BUCKET"
  #   prefix = "sdp"
  # }
}
