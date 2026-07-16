-- Mixed PII coverage table: one row class per major infoType plus controls.
-- FREETEXT_COLUMNS=content
-- Synthetic PII only. Loaded via google_bigquery_job destination_table.
SELECT 1 AS id, 'person_name' AS record_type, 'The account owner is Michael Chen.' AS content
UNION ALL
SELECT 2, 'email', 'Primary contact: support.user@example.com'
UNION ALL
SELECT 3, 'phone', 'Reach the customer at 800-555-0199 during business hours.'
UNION ALL
SELECT 4, 'ssn', 'Taxpayer ID recorded as 111-22-3333 for verification.'
UNION ALL
SELECT 5, 'credit_card', 'Payment method 4111111111111111 was declined twice.'
UNION ALL
SELECT 6, 'date_of_birth', 'Member date of birth is 07/04/1976 per ID check.'
UNION ALL
SELECT 7, 'street_address', 'Deliver replacement to 789 Pine Road, Seattle, WA 98101.'
UNION ALL
SELECT 8, 'mixed', 'Call Sarah Connor at sarah.connor@skynet.example or 310-555-0101; SSN 222-33-4444.'
UNION ALL
SELECT 9, 'clean', 'Inventory count completed for warehouse zone B with no issues.'
UNION ALL
SELECT 10, 'null_content', CAST(NULL AS STRING)
UNION ALL
SELECT 11, 'empty_content', ''
