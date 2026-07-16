-- Simple single-freetext-column sample table for basic pipeline tests.
-- Synthetic PII only. Loaded via google_bigquery_job destination_table.
SELECT 1 AS id, 'Contact John Doe at john@example.com or 555-123-4567' AS notes
UNION ALL
SELECT 2, 'SSN 123-45-6789, born 01/15/1985'
UNION ALL
SELECT 3, 'No PII here, just a product review.'
UNION ALL
SELECT 4, 'Ship to 123 Main Street, Springfield, IL 62701 for Alice Smith'
UNION ALL
SELECT 5, 'Card on file ends with 4111-1111-1111-1111 — call (415) 555-0199'
UNION ALL
SELECT 6, CAST(NULL AS STRING)
UNION ALL
SELECT 7, ''
