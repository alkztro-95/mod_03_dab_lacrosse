-- Validate that gold layer has data
SELECT
  COUNT(*) AS row_count,
  CASE
    WHEN COUNT(*) > 1 THEN 'PASS'
    ELSE 'FAIL'
  END AS validation_status
FROM dab_lacrosse_dev.03_gold.daily_sales_summary
