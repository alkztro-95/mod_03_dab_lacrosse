-- Validate that gold layer has data
SELECT
  COUNT(*) AS row_count,
  CASE
    WHEN COUNT(*) > CAST('{{job.parameters.min_row_threshold}}' AS INT) THEN 'PASS'
    ELSE 'FAIL'
  END AS validation_status
FROM {{job.parameters.catalog_name}}.{{job.parameters.schema_gold}}.daily_sales_summary
