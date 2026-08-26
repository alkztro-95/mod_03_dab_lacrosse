-- Silver Layer: Sales Fact Table (Cleaned and Enriched)
-- Streaming Table with data quality constraints and derived columns
-- Links to customers and stores through foreign keys

CREATE OR REFRESH STREAMING TABLE ${catalog}.${schema_silver}.fact_sales
(
  -- EXPECTATION 1: Total amount should be positive (WARN)
  -- Justification: Puede haber devoluciones o ajustes que queremos investigar,
  --               pero no bloquear la ingesta. WARN nos alerta sin fallar.
  CONSTRAINT positive_amount EXPECT (total_amount > 0),
  
  -- EXPECTATION 2: Must have valid customer and store references (DROP ROW)
  -- Justification: Sin referencias a customer/store, la transacción no aporta
  --               valor analítico. Se descarta pero no falla el pipeline.
  CONSTRAINT valid_references EXPECT (customer_id IS NOT NULL AND store_id IS NOT NULL) ON VIOLATION DROP ROW
)
COMMENT 'Silver layer - Sales fact table with derived columns and data quality constraints.'
AS SELECT
  -- Primary key and foreign keys
  transaction_id,
  customer_id,
  store_id,
  
  -- Store attributes (denormalized for convenience)
  TRIM(store_name) as store_name,
  TRIM(city) as city,
  TRIM(region) as region,
  TRIM(location_type) as location_type,
  
  -- Product information
  product_id,
  TRIM(product_name) as product_name,
  TRIM(category) as category,
  TRIM(sub_department) as sub_department,
  
  -- Transaction details (proper typing)
  CAST(quantity AS INT) as quantity,
  CAST(unit_price AS DOUBLE) as unit_price,
  CAST(discount AS DOUBLE) as discount,
  CAST(total_amount AS DOUBLE) as total_amount,
  
  -- Payment and timing
  UPPER(TRIM(payment_method)) as payment_method,
  CAST(transaction_date AS TIMESTAMP) as transaction_date,
  
  -- DERIVED COLUMNS
  -- Calculate discount percentage
  CASE 
    WHEN (unit_price * quantity) > 0 
    THEN ROUND((discount / (unit_price * quantity)) * 100, 2)
    ELSE 0.0
  END as discount_percentage,
  
  -- Flag high-value transactions
  CASE 
    WHEN total_amount >= 1000 THEN true 
    ELSE false 
  END as is_high_value,
  
  -- Extract time dimensions
  DATE(transaction_date) as transaction_date_only,
  YEAR(transaction_date) as transaction_year,
  MONTH(transaction_date) as transaction_month,
  DAYOFWEEK(transaction_date) as transaction_day_of_week,
  
  -- Metadata
  current_timestamp() as _processing_timestamp
  
FROM STREAM(${catalog}.${schema_bronze}.bronze_sales_transactions);