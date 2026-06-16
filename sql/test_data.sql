-- Replace dataset name before running.
CREATE OR REPLACE TABLE `PROJECT_ID.sdp_test.test_notes` AS
SELECT 1 AS id, 'Contact John Doe at john@example.com or 555-123-4567' AS notes
UNION ALL
SELECT 2, 'SSN 123-45-6789, born 01/15/1985'
UNION ALL
SELECT 3, 'No PII here, just a product review.';