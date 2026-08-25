-- Validate that gold layer has data
SELECT
  assert_true(
    COUNT(*) > 1,
    'Gold layer validation failed: daily_sales_summary has insufficient data'
  ) AS validation_status
FROM dab_lacrosse_dev.03_gold.daily_sales_summary
