resource "google_cloud_run_v2_job" "masker" {
  name                = var.job_name
  project             = var.project_id
  location            = var.region
  deletion_protection = false

  template {
    template {
      service_account = google_service_account.pipeline.email
      timeout         = "3600s"
      max_retries     = 1

      containers {
        image = local.image

        resources {
          limits = {
            cpu    = "1"
            memory = "1Gi"
          }
        }

        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "SOURCE_TABLE"
          value = local.default_source_table
        }
        env {
          name  = "TARGET_TABLE"
          value = local.default_target_table
        }
        env {
          name  = "FREETEXT_COLUMNS"
          value = "notes"
        }
        env {
          name  = "INSPECT_TEMPLATE"
          value = google_data_loss_prevention_inspect_template.freetext.id
        }
        env {
          name  = "DEIDENTIFY_TEMPLATE"
          value = google_data_loss_prevention_deidentify_template.freetext.id
        }
        env {
          name  = "BATCH_SIZE"
          value = tostring(var.batch_size)
        }
        env {
          name  = "DLP_CHUNK_SIZE"
          value = tostring(var.dlp_chunk_size)
        }
        env {
          name  = "DLP_LOCATION"
          value = var.dlp_location
        }
        env {
          name  = "DRY_RUN"
          value = "false"
        }
      }
    }
  }

  depends_on = [
    google_project_service.required,
    google_artifact_registry_repository.pipeline,
    google_bigquery_job.seed_test_notes,
  ]

  # Image tag is often updated by Cloud Build without a TF apply.
  lifecycle {
    ignore_changes = [
      template[0].template[0].containers[0].image,
      client,
      client_version,
    ]
  }
}
