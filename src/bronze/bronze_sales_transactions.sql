-- Bronze Layer: Sales Transactions (Main Fact Table)
-- Ingest sales transaction data with Auto Loader
-- Links customers and stores through foreign keys
-- Add a comment for deployment.

CREATE OR REFRESH STREAMING TABLE ${catalog}.${schema_bronze}.bronze_sales_transactions
COMMENT 'Bronze layer - Raw sales transaction data ingested with Auto Loader.'
AS SELECT 
  *,
  current_timestamp() as _ingestion_timestamp,
  _metadata.file_path as _source_file
FROM cloud_files(
  '/Volumes/${catalog}/${schema_bronze}/landing_zone/sales_transactions/',
  'csv',
  map(
    'cloudFiles.inferColumnTypes', 'true',
    'header', 'true'
  )
);