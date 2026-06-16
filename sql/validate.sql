-- Replace dataset/table names before running.

-- Row counts should match.
SELECT
  (SELECT COUNT(*) FROM `PROJECT_ID.sdp_test.test_notes`) AS source_rows,
  (SELECT COUNT(*) FROM `PROJECT_ID.sdp_test.test_notes_masked`) AS masked_rows;

-- Expect zero rows: raw email/SSN patterns should be gone.
SELECT *
FROM `PROJECT_ID.sdp_test.test_notes_masked`
WHERE REGEXP_CONTAINS(notes, r'@|john@example|123-45-6789');

-- Spot-check masked output.
SELECT id, notes
FROM `PROJECT_ID.sdp_test.test_notes_masked`
ORDER BY id;