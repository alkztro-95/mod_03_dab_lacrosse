-- Gold Layer: Sales Performance Metrics
-- Aggregated sales metrics by time period, store, region, category, and customer segments
-- Materialized View - reads from Silver layer in batch mode

-- ============================================================
-- Metric 1: Daily Sales Aggregates
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.daily_sales_summary
COMMENT 'Gold metric - Daily sales aggregates with key metrics'
AS SELECT
  transaction_date_only as sale_date,
  COUNT(DISTINCT transaction_id) as total_transactions,
  COUNT(DISTINCT customer_id) as unique_customers,
  COUNT(DISTINCT store_id) as active_stores,
  SUM(total_amount) as total_revenue,
  AVG(total_amount) as avg_transaction_value,
  SUM(quantity) as total_units_sold,
  SUM(CASE WHEN is_high_value = true THEN 1 ELSE 0 END) as high_value_transactions,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.fact_sales
GROUP BY transaction_date_only
ORDER BY sale_date DESC;

-- ============================================================
-- Metric 2: Monthly Sales Aggregates
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.monthly_sales_summary
COMMENT 'Gold metric - Monthly sales aggregates with growth metrics'
AS SELECT
  transaction_year,
  transaction_month,
  COUNT(DISTINCT transaction_id) as total_transactions,
  SUM(total_amount) as total_revenue,
  AVG(total_amount) as avg_transaction_value,
  SUM(quantity) as total_units_sold,
  COUNT(DISTINCT customer_id) as unique_customers,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.fact_sales
GROUP BY transaction_year, transaction_month
ORDER BY transaction_year DESC, transaction_month DESC;

-- ============================================================
-- Metric 3: Sales by Store
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.sales_by_store
COMMENT 'Gold metric - Sales performance by store'
AS SELECT
  s.store_id,
  s.store_name,
  s.city,
  s.region,
  s.location_type,
  COUNT(DISTINCT f.transaction_id) as total_transactions,
  SUM(f.total_amount) as total_revenue,
  AVG(f.total_amount) as avg_transaction_value,
  COUNT(DISTINCT f.customer_id) as unique_customers,
  SUM(f.quantity) as total_units_sold,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.fact_sales f
INNER JOIN ${catalog}.${schema_silver}.dim_stores s
  ON f.store_id = s.store_id
GROUP BY ALL
ORDER BY total_revenue DESC;

-- ============================================================
-- Metric 4: Sales by Region
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.sales_by_region
COMMENT 'Gold metric - Regional sales performance comparison'
AS SELECT
  f.region,
  COUNT(DISTINCT f.transaction_id) as total_transactions,
  SUM(f.total_amount) as total_revenue,
  AVG(f.total_amount) as avg_transaction_value,
  COUNT(DISTINCT f.store_id) as store_count,
  COUNT(DISTINCT f.customer_id) as unique_customers,
  ROUND(SUM(f.total_amount) * 100.0 / SUM(SUM(f.total_amount)) OVER (), 2) as revenue_percentage,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.fact_sales f
INNER JOIN ${catalog}.${schema_silver}.dim_stores s
  ON f.store_id = s.store_id
GROUP BY f.region
ORDER BY total_revenue DESC;

-- ============================================================
-- Metric 5: Sales by Category
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.sales_by_category
COMMENT 'Gold metric - Product category performance'
AS SELECT
  category,
  COUNT(DISTINCT transaction_id) as total_transactions,
  SUM(total_amount) as total_revenue,
  AVG(total_amount) as avg_transaction_value,
  SUM(quantity) as total_units_sold,
  COUNT(DISTINCT customer_id) as unique_customers,
  ROUND(SUM(total_amount) * 100.0 / SUM(SUM(total_amount)) OVER (), 2) as revenue_percentage,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.fact_sales
GROUP BY category
ORDER BY total_revenue DESC;

-- ============================================================
-- Metric 6: Average Order Value by Customer Tier
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.aov_by_customer_tier
COMMENT 'Gold metric - Average order value segmented by loyalty tier'
AS SELECT
  c.loyalty_tier,
  COUNT(DISTINCT f.transaction_id) as total_transactions,
  SUM(f.total_amount) as total_revenue,
  AVG(f.total_amount) as avg_order_value,
  COUNT(DISTINCT f.customer_id) as unique_customers,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.fact_sales f
INNER JOIN ${catalog}.${schema_silver}.dim_customers c
  ON f.customer_id = c.customer_id
WHERE c.__END_AT IS NULL  -- Only current customers
GROUP BY c.loyalty_tier
ORDER BY avg_order_value DESC;

-- ============================================================
-- Metric 7: Top Products by Revenue
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.top_products_by_revenue
COMMENT 'Gold metric - Top performing products ranked by revenue'
AS SELECT
  product_id,
  product_name,
  category,
  sub_department,
  COUNT(DISTINCT transaction_id) as total_transactions,
  SUM(total_amount) as total_revenue,
  SUM(quantity) as total_units_sold,
  AVG(unit_price) as avg_price,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.fact_sales
GROUP BY ALL
ORDER BY total_revenue DESC
LIMIT 100;
