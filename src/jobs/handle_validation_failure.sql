-- Log validation failure
SELECT
  current_timestamp() AS failure_timestamp,
  '{{job.parameters.catalog_name}}' AS catalog,
  '{{job.parameters.schema_gold}}' AS schema,
  'Gold layer validation failed - insufficient data' AS error_message
