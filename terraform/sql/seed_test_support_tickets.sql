-- Multi-freetext-column sample table.
-- FREETEXT_COLUMNS=subject,body,internal_notes
-- Synthetic PII only.
CREATE OR REPLACE TABLE `${project_id}.${dataset_id}.test_support_tickets` AS
SELECT
  1001 AS ticket_id,
  'Cannot login — email Jane Roe at jane.roe@example.org' AS subject,
  'Hi, my phone is 212-555-0147 and I live at 456 Oak Ave, Austin, TX 78701. Please help.' AS body,
  'Caller verified DOB 03/22/1990. Account SSN on file 987-65-4321.' AS internal_notes,
  'high' AS priority
UNION ALL
SELECT
  1002,
  'Billing dispute',
  'I was charged on card 5500-0000-0000-0004. Please refund.',
  'No additional PII collected.',
  'medium'
UNION ALL
SELECT
  1003,
  'Feature request: dark mode',
  'Loving the product. No personal details needed.',
  '',
  'low'
UNION ALL
SELECT
  1004,
  'Account recovery for Bob Martinez',
  CAST(NULL AS STRING),
  'Left voicemail at +1-650-555-0182',
  'high'
UNION ALL
SELECT
  1005,
  'General feedback',
  'The dashboard is fast and easy to use.',
  CAST(NULL AS STRING),
  'low';
