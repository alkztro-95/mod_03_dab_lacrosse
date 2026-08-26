-- Silver Layer: Customer Dimension with AUTO CDC and SCD Type 2
-- Automatically tracks historical changes in customer records
-- Databricks manages __START_AT, __END_AT, and __IS_CURRENT columns

-- First, declare the target table
CREATE OR REFRESH STREAMING TABLE ${catalog}.${schema_silver}.dim_customers;

-- Then, apply CDC changes with SCD Type 2
APPLY CHANGES INTO ${catalog}.${schema_silver}.dim_customers
FROM STREAM(${catalog}.${schema_bronze}.bronze_customers)
KEYS (customer_id)
APPLY AS DELETE WHEN operation = 'DELETE'
SEQUENCE BY updated_at
COLUMNS * EXCEPT (operation, _rescued_data, _ingestion_timestamp, _source_file)
STORED AS SCD TYPE 2;