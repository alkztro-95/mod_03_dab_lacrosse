-- Bronze Layer: Stores (Static Reference Data)
-- Ingest store information with Auto Loader
-- This is reference data that changes infrequently

CREATE OR REFRESH STREAMING TABLE ${catalog}.${schema_bronze}.bronze_stores
COMMENT 'Bronze layer - Raw store reference data ingested with Auto Loader.'
AS SELECT 
  *,
  current_timestamp() as _ingestion_timestamp,
  _metadata.file_path as _source_file
FROM cloud_files(
  '/Volumes/${catalog}/${schema_bronze}/landing_zone/stores/',
  'csv',
  map(
    'cloudFiles.inferColumnTypes', 'true',
    'header', 'true'
  )
);