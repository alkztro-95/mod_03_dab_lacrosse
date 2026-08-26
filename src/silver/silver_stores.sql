-- Silver Layer: Store Dimension (Cleaned Reference Data)
-- Materialized View - Static reference data
-- Data Quality: Expectations with FAIL and DROP behaviors

CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_silver}.dim_stores
(
  -- EXPECTATION 1: Store ID must exist (FAIL UPDATE)
  -- Justification: Un store sin ID rompe toda la integridad referencial;
  --               mejor fallar y corregir en origen que propagar datos inválidos
  CONSTRAINT valid_store_id EXPECT (store_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
  
  -- EXPECTATION 2: Region must be valid (DROP ROW)
  -- Justification: Una tienda con región inválida es error de captura;
  --               se descarta la fila pero no falla todo el pipeline
  CONSTRAINT valid_region EXPECT (region IN ('NORTHEAST', 'SOUTHEAST', 'MIDWEST', 'SOUTH', 'WEST')) ON VIOLATION DROP ROW
)
COMMENT 'Silver layer - Cleaned and validated store reference data with data quality constraints.'
AS SELECT
  store_id,
  TRIM(store_name) as store_name,
  TRIM(city) as city,
  UPPER(TRIM(region)) as region,  -- Normalize region to uppercase
  TRIM(location_type) as location_type,
  current_timestamp() as _processing_timestamp
FROM ${catalog}.${schema_bronze}.bronze_stores;