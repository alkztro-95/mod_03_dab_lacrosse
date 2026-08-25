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

-- How SCD Type 2 works:
-- 1. INSERT: Creates new record with __END_AT = NULL, __IS_CURRENT = true
-- 2. UPDATE: Closes previous version (__END_AT = updated_at, __IS_CURRENT = false),
--           opens new version with __END_AT = NULL, __IS_CURRENT = true
-- 3. DELETE: Closes current version (__END_AT = updated_at, __IS_CURRENT = false),
--           does NOT create a new record
--
-- Query current state: WHERE __IS_CURRENT = true
-- Query at specific time: WHERE __START_AT <= timestamp AND (timestamp < __END_AT OR __END_AT IS NULL)