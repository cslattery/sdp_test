-- Replace PROJECT_ID before running (or set via bq --project_id).
-- Expected masked tables are created by the pipeline (not Terraform).

-- ---------------------------------------------------------------------------
-- test_notes
-- ---------------------------------------------------------------------------
SELECT
  'test_notes' AS table_pair,
  (SELECT COUNT(*) FROM `PROJECT_ID.sdp_test.test_notes`) AS source_rows,
  (SELECT COUNT(*) FROM `PROJECT_ID.sdp_test.test_notes_masked`) AS masked_rows;

-- Expect zero rows: raw email/SSN patterns should be gone from non-null notes.
SELECT *
FROM `PROJECT_ID.sdp_test.test_notes_masked`
WHERE notes IS NOT NULL
  AND notes != ''
  AND REGEXP_CONTAINS(notes, r'john@example\.com|123-45-6789|4111-1111-1111-1111');

SELECT id, notes
FROM `PROJECT_ID.sdp_test.test_notes_masked`
ORDER BY id;

-- ---------------------------------------------------------------------------
-- test_support_tickets
-- ---------------------------------------------------------------------------
SELECT
  'test_support_tickets' AS table_pair,
  (SELECT COUNT(*) FROM `PROJECT_ID.sdp_test.test_support_tickets`) AS source_rows,
  (SELECT COUNT(*) FROM `PROJECT_ID.sdp_test.test_support_tickets_masked`) AS masked_rows;

SELECT ticket_id, subject, body, internal_notes
FROM `PROJECT_ID.sdp_test.test_support_tickets_masked`
ORDER BY ticket_id;

-- ---------------------------------------------------------------------------
-- test_mixed_pii
-- ---------------------------------------------------------------------------
SELECT
  'test_mixed_pii' AS table_pair,
  (SELECT COUNT(*) FROM `PROJECT_ID.sdp_test.test_mixed_pii`) AS source_rows,
  (SELECT COUNT(*) FROM `PROJECT_ID.sdp_test.test_mixed_pii_masked`) AS masked_rows;

SELECT id, record_type, content
FROM `PROJECT_ID.sdp_test.test_mixed_pii_masked`
ORDER BY id;
