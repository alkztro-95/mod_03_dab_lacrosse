-- Gold Layer: transaction-level enrichment with the SCD Type 2 customer version
-- Each transaction joins to the customer record valid at transaction time.

CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.gold_customer_sales_store_enriched
COMMENT 'Gold transaction dataset joined to the valid customer SCD2 version and store dimension.'
AS
SELECT
  f.transaction_id,
  f.transaction_date,
  f.transaction_date_only,
  f.customer_id,
  f.store_id,
  f.product_id,
  f.product_name,
  f.category,
  f.sub_department,
  f.quantity,
  f.unit_price,
  f.discount,
  f.discount_percentage,
  f.total_amount,
  f.is_high_value,
  f.payment_method,
  f.transaction_year,
  f.transaction_month,
  f.transaction_day_of_week,
  c.first_name AS customer_first_name,
  c.last_name AS customer_last_name,
  c.loyalty_tier AS customer_loyalty_tier,
  c.state AS customer_state,
  c.city AS customer_city,
  c.__START_AT AS customer_valid_from,
  c.__END_AT AS customer_valid_to,
  s.store_name,
  s.city AS store_city,
  s.region AS store_region,
  s.location_type AS store_location_type
FROM ${catalog}.${schema_silver}.fact_sales AS f
LEFT JOIN ${catalog}.${schema_silver}.dim_customers AS c
  ON f.customer_id = c.customer_id
  AND f.transaction_date >= c.__START_AT
  AND (c.__END_AT IS NULL OR f.transaction_date < c.__END_AT)
LEFT JOIN ${catalog}.${schema_silver}.dim_stores AS s
  ON f.store_id = s.store_id;
