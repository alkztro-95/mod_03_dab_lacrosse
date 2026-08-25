-- Gold Layer: Store Performance Metric View
-- Semantic layer for store-level performance metrics
-- Combines fact_sales with dim_stores and SCD2 dim_customers

CREATE OR REPLACE VIEW dab_lacrosse_dev.03_gold.mv_store_performance
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  
  source: dab_lacrosse_dev.02_silver.fact_sales
  
  comment: Store performance metric view with regional and location-type analysis
  
  joins:
    - name: stores
      source: dab_lacrosse_dev.02_silver.dim_stores
      on: source.store_id = stores.store_id
    - name: customers
      source: dab_lacrosse_dev.02_silver.dim_customers
      on: source.customer_id = customers.customer_id AND customers.__END_AT IS NULL
  
  dimensions:
    - name: store_name
      expr: stores.store_name
      display_name: Store Name
      comment: Name of the store
      
    - name: region
      expr: stores.region
      display_name: Region
      comment: Geographic region (NORTHEAST, MIDWEST, SOUTHEAST, SOUTH, WEST)
      synonyms:
        - store region
        - geographic region
        
    - name: location_type
      expr: stores.location_type
      display_name: Location Type
      comment: Type of store location (Downtown, Suburban, Mall)
      synonyms:
        - store type
        
    - name: city
      expr: stores.city
      display_name: Store City
      comment: City where store is located
      
    - name: loyalty_tier
      expr: customers.loyalty_tier
      display_name: Customer Loyalty Tier
      comment: Loyalty tier of customers shopping at the store
      
  measures:
    - name: total_revenue
      expr: SUM(source.total_amount)
      display_name: Total Revenue
      comment: Total revenue generated
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      synonyms:
        - revenue
        - sales
        
    - name: transaction_count
      expr: COUNT(DISTINCT source.transaction_id)
      display_name: Transaction Count
      comment: Number of transactions
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
      synonyms:
        - order count
        
    - name: unique_customers
      expr: COUNT(DISTINCT source.customer_id)
      display_name: Unique Customers
      comment: Number of unique customers who shopped
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
          
    - name: avg_transaction_value
      expr: MEASURE(total_revenue) / MEASURE(transaction_count)
      display_name: Average Transaction Value
      comment: Average value per transaction
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      synonyms:
        - aov
        
    - name: total_units_sold
      expr: SUM(source.quantity)
      display_name: Total Units Sold
      comment: Total quantity of products sold
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
          
    - name: transactions_per_customer
      expr: MEASURE(transaction_count) / MEASURE(unique_customers)
      display_name: Transactions per Customer
      comment: Average number of transactions per unique customer
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
      synonyms:
        - purchase frequency
$$;
