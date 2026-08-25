-- Bronze Layer: Customers (CDC Source)
-- Ingest raw CSV files with Auto Loader
-- Preserves all columns including 'operation' and 'updated_at' for CDC processing

CREATE OR REFRESH STREAMING TABLE ${catalog}.${schema_bronze}.bronze_customers
COMMENT 'Bronze layer - Raw customer data ingested with Auto Loader. Contains CDC operation markers.'
AS SELECT 
  *,
  current_timestamp() as _ingestion_timestamp,
  _metadata.file_path as _source_file
FROM cloud_files(
  '/Volumes/${catalog}/${schema_bronze}/landing_zone/customers/',
  'csv',
  map(
    'cloudFiles.inferColumnTypes', 'true',
    'header', 'true'
  )
);