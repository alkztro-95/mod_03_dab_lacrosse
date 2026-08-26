-- Gold Layer: materialized mirrors of the current Silver datasets
-- Metric Views consume these Gold objects instead of reading Silver directly.

CREATE OR REFRESH MATERIALIZED VIEW dab_lacrosse_dev.03_gold.gold_dim_customers
COMMENT 'Gold mirror of the current Silver customer dimension.'
AS SELECT *
FROM dab_lacrosse_dev.02_silver.dim_customers
WHERE __END_AT IS NULL;

CREATE OR REFRESH MATERIALIZED VIEW dab_lacrosse_dev.03_gold.gold_fact_sales
COMMENT 'Gold mirror of the Silver sales fact table.'
AS SELECT *
FROM dab_lacrosse_dev.02_silver.fact_sales;

CREATE OR REFRESH MATERIALIZED VIEW dab_lacrosse_dev.03_gold.gold_dim_stores
COMMENT 'Gold mirror of the Silver store dimension.'
AS SELECT *
FROM dab_lacrosse_dev.02_silver.dim_stores;
