-- Fallback seed SQL (non-Terraform). Prefer: cd terraform && terraform apply
-- Replace PROJECT_ID before running, or use terraform/sql seeds which are templated.
-- Synthetic PII only.

-- Simple notes table
CREATE OR REPLACE TABLE `PROJECT_ID.sdp_test.test_notes` AS
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
SELECT 7, '';

-- Multi-column support tickets (FREETEXT_COLUMNS=subject,body,internal_notes)
CREATE OR REPLACE TABLE `PROJECT_ID.sdp_test.test_support_tickets` AS
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

-- Mixed PII coverage (FREETEXT_COLUMNS=content)
CREATE OR REPLACE TABLE `PROJECT_ID.sdp_test.test_mixed_pii` AS
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
SELECT 11, 'empty_content', '';
