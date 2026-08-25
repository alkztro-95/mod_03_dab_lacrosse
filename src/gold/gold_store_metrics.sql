-- Gold Layer: Store Performance Metrics
-- Aggregated metrics analyzing store performance by location type, region, and ranking
-- Materialized View - reads from Silver layer in batch mode

-- ============================================================
-- Metric 1: Sales by Store Location Type
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.sales_by_location_type
COMMENT 'Gold metric - Performance comparison by store location type (Downtown, Suburban, Mall)'
AS SELECT
  s.location_type,
  COUNT(DISTINCT s.store_id) as store_count,
  COUNT(DISTINCT f.transaction_id) as total_transactions,
  SUM(f.total_amount) as total_revenue,
  AVG(f.total_amount) as avg_transaction_value,
  SUM(f.quantity) as total_units_sold,
  COUNT(DISTINCT f.customer_id) as unique_customers,
  ROUND(SUM(f.total_amount) / COUNT(DISTINCT s.store_id), 2) as revenue_per_store,
  ROUND(SUM(f.total_amount) * 100.0 / SUM(SUM(f.total_amount)) OVER (), 2) as revenue_percentage,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.fact_sales f
INNER JOIN ${catalog}.${schema_silver}.dim_stores s
  ON f.store_id = s.store_id
GROUP BY s.location_type
ORDER BY total_revenue DESC;

-- ============================================================
-- Metric 2: Store Ranking by Revenue
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.store_revenue_ranking
COMMENT 'Gold metric - Top performing stores ranked by total revenue'
AS SELECT
  ROW_NUMBER() OVER (ORDER BY SUM(f.total_amount) DESC) as revenue_rank,
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
  ROUND(SUM(f.total_amount) * 100.0 / SUM(SUM(f.total_amount)) OVER (), 2) as revenue_percentage,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.fact_sales f
INNER JOIN ${catalog}.${schema_silver}.dim_stores s
  ON f.store_id = s.store_id
GROUP BY ALL
ORDER BY total_revenue DESC;

-- ============================================================
-- Metric 3: Regional Performance Comparison
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.regional_performance_comparison
COMMENT 'Gold metric - Comprehensive regional performance comparison with rankings'
AS SELECT
  ROW_NUMBER() OVER (ORDER BY SUM(f.total_amount) DESC) as revenue_rank,
  s.region,
  COUNT(DISTINCT s.store_id) as store_count,
  COUNT(DISTINCT f.transaction_id) as total_transactions,
  SUM(f.total_amount) as total_revenue,
  AVG(f.total_amount) as avg_transaction_value,
  COUNT(DISTINCT f.customer_id) as unique_customers,
  SUM(f.quantity) as total_units_sold,
  ROUND(SUM(f.total_amount) / COUNT(DISTINCT s.store_id), 2) as revenue_per_store,
  ROUND(COUNT(DISTINCT f.transaction_id) / COUNT(DISTINCT s.store_id), 2) as transactions_per_store,
  ROUND(SUM(f.total_amount) * 100.0 / SUM(SUM(f.total_amount)) OVER (), 2) as revenue_percentage,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.fact_sales f
INNER JOIN ${catalog}.${schema_silver}.dim_stores s
  ON f.store_id = s.store_id
GROUP BY s.region
ORDER BY total_revenue DESC;

-- ============================================================
-- Metric 4: Store Efficiency Metrics
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.store_efficiency_metrics
COMMENT 'Gold metric - Store operational efficiency indicators'
AS SELECT
  s.store_id,
  s.store_name,
  s.region,
  s.location_type,
  COUNT(DISTINCT f.transaction_id) as total_transactions,
  SUM(f.total_amount) as total_revenue,
  AVG(f.total_amount) as avg_transaction_value,
  SUM(f.quantity) as total_units_sold,
  ROUND(SUM(f.total_amount) / COUNT(DISTINCT f.transaction_id), 2) as revenue_per_transaction,
  ROUND(SUM(f.quantity) / COUNT(DISTINCT f.transaction_id), 2) as units_per_transaction,
  COUNT(DISTINCT f.customer_id) as unique_customers,
  ROUND(COUNT(DISTINCT f.transaction_id) * 1.0 / COUNT(DISTINCT f.customer_id), 2) as transactions_per_customer,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.fact_sales f
INNER JOIN ${catalog}.${schema_silver}.dim_stores s
  ON f.store_id = s.store_id
GROUP BY ALL
ORDER BY total_revenue DESC;

-- ============================================================
-- Metric 5: Store Performance by Day of Week
-- ============================================================
CREATE OR REFRESH MATERIALIZED VIEW ${catalog}.${schema_gold}.store_performance_by_day
COMMENT 'Gold metric - Store sales patterns by day of week'
AS SELECT
  s.store_id,
  s.store_name,
  s.region,
  f.transaction_day_of_week,
  COUNT(DISTINCT f.transaction_id) as total_transactions,
  SUM(f.total_amount) as total_revenue,
  AVG(f.total_amount) as avg_transaction_value,
  current_timestamp() as _metric_timestamp
FROM ${catalog}.${schema_silver}.fact_sales f
INNER JOIN ${catalog}.${schema_silver}.dim_stores s
  ON f.store_id = s.store_id
GROUP BY ALL
ORDER BY s.store_id, f.transaction_day_of_week;
