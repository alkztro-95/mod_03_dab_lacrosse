-- Validate that each metric view contains data.
SELECT assert_true(
  COUNT(*) > 0,
  'Metric view is empty'
) AS validation_status
FROM IDENTIFIER(:table_name)
