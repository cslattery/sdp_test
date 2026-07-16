resource "google_data_loss_prevention_inspect_template" "freetext" {
  parent       = local.dlp_parent
  description  = "Detects common PII infoTypes in unstructured freetext columns."
  display_name = "Freetext PII inspect"
  template_id  = "freetext-pii-inspect"

  inspect_config {
    dynamic "info_types" {
      for_each = local.info_types
      content {
        name = info_types.value
      }
    }

    min_likelihood = "POSSIBLE"

    limits {
      max_findings_per_item    = 0
      max_findings_per_request = 0
    }
  }

  depends_on = [google_project_service.required]
}

resource "google_data_loss_prevention_deidentify_template" "freetext" {
  parent       = local.dlp_parent
  description  = "Replaces detected PII in freetext with infoType placeholders."
  display_name = "Freetext PII masker"
  template_id  = "freetext-pii-deidentify"

  deidentify_config {
    info_type_transformations {
      transformations {
        dynamic "info_types" {
          for_each = local.info_types
          content {
            name = info_types.value
          }
        }

        primitive_transformation {
          replace_with_info_type_config = true
        }
      }
    }
  }

  depends_on = [google_project_service.required]
}
