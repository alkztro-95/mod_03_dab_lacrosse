-- Gold Layer: Customer Analytics
-- Aggregated metrics about customers, loyalty tiers, and geographic distribution
-- Materialized View - reads from Silver layer in batch mode

-- ============================================================
-- Metric 1: Customers by Loyalty Tier
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.customers_by_loyalty_tier
COMMENT 'Gold metric - Customer count and percentage by loyalty tier'
AS SELECT
  loyalty_tier,
  COUNT(DISTINCT customer_id) as customer_count,
  ROUND(COUNT(DISTINCT customer_id) * 100.0 / SUM(COUNT(DISTINCT customer_id)) OVER (), 2) as percentage,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.dim_customers
WHERE __END_AT IS NULL  -- Only current active customers (SCD Type 2)
GROUP BY loyalty_tier
ORDER BY customer_count DESC;

-- ============================================================
-- Metric 2: Customers by Region/State
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.customers_by_region
COMMENT 'Gold metric - Customer distribution by geographic location'
AS SELECT
  state,
  COUNT(DISTINCT customer_id) as customer_count,
  ROUND(COUNT(DISTINCT customer_id) * 100.0 / SUM(COUNT(DISTINCT customer_id)) OVER (), 2) as percentage,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.dim_customers
WHERE __END_AT IS NULL  -- Only current active customers
GROUP BY state
ORDER BY customer_count DESC;

-- ============================================================
-- Metric 3: Customer Lifetime Value (CLV)
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.customer_lifetime_value
COMMENT 'Gold metric - Customer lifetime value by customer and loyalty tier'
AS SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  c.loyalty_tier,
  c.state,
  COUNT(DISTINCT s.transaction_id) as total_transactions,
  SUM(s.total_amount) as lifetime_value,
  AVG(s.total_amount) as avg_transaction_value,
  MIN(s.transaction_date) as first_purchase_date,
  MAX(s.transaction_date) as last_purchase_date,
  DATEDIFF(MAX(s.transaction_date), MIN(s.transaction_date)) as customer_tenure_days,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.dim_customers c
INNER JOIN ${catalog}.${schema_silver}.fact_sales s
  ON c.customer_id = s.customer_id
WHERE c.__END_AT IS NULL  -- Only current active customers
GROUP BY ALL
ORDER BY lifetime_value DESC;

-- ============================================================
-- Metric 4: Active vs Inactive Customers
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.customer_activity_status
COMMENT 'Gold metric - Customer activity status (active = purchased in last 90 days)'
AS SELECT
  CASE 
    WHEN MAX(s.transaction_date) >= DATE_SUB(CURRENT_DATE(), 90) THEN 'Active'
    ELSE 'Inactive'
  END as activity_status,
  COUNT(DISTINCT c.customer_id) as customer_count,
  ROUND(COUNT(DISTINCT c.customer_id) * 100.0 / SUM(COUNT(DISTINCT c.customer_id)) OVER (), 2) as percentage,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.dim_customers c
LEFT JOIN ${catalog}.${schema_silver}.fact_sales s
  ON c.customer_id = s.customer_id
WHERE c.__END_AT IS NULL  -- Only current active customers
GROUP BY ALL;
