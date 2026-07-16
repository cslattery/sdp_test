locals {
  image = coalesce(
    var.image,
    "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repo}/sdp-bq-masker:latest"
  )

  dlp_parent = "projects/${var.project_id}/locations/${var.dlp_location}"

  info_types = [
    "PERSON_NAME",
    "EMAIL_ADDRESS",
    "PHONE_NUMBER",
    "US_SOCIAL_SECURITY_NUMBER",
    "CREDIT_CARD_NUMBER",
    "DATE_OF_BIRTH",
    "STREET_ADDRESS",
  ]

  fq_dataset = "${var.project_id}.${var.dataset_id}"

  sample_table_ids = {
    test_notes           = "test_notes"
    test_support_tickets = "test_support_tickets"
    test_mixed_pii       = "test_mixed_pii"
  }

  sample_tables = {
    for key, table_id in local.sample_table_ids :
    key => "${local.fq_dataset}.${table_id}"
  }

  default_source_table = local.sample_tables.test_notes
  default_target_table = "${local.fq_dataset}.test_notes_masked"

  seed_test_notes_sql = templatefile("${path.module}/sql/seed_test_notes.sql", {
    project_id = var.project_id
    dataset_id = var.dataset_id
  })

  seed_test_support_tickets_sql = templatefile("${path.module}/sql/seed_test_support_tickets.sql", {
    project_id = var.project_id
    dataset_id = var.dataset_id
  })

  seed_test_mixed_pii_sql = templatefile("${path.module}/sql/seed_test_mixed_pii.sql", {
    project_id = var.project_id
    dataset_id = var.dataset_id
  })
}
