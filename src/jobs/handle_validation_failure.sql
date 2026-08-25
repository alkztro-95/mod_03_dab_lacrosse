-- Log validation failure
SELECT
  current_timestamp() AS failure_timestamp,
  'dab_lacrosse_dev' AS catalog,
  '03_gold' AS schema,
  'Gold layer validation failed - insufficient data' AS error_message
