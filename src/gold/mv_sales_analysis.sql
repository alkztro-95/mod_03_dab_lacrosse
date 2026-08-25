-- Gold Layer: Sales Analysis Metric View
-- Semantic layer with measures and dimensions for sales analytics
-- Joins fact_sales with SCD2 dim_customers (current records only)

CREATE OR REPLACE VIEW dab_lacrosse_dev.03_gold.mv_sales_analysis
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  
  source: dab_lacrosse_dev.02_silver.fact_sales
  
  comment: Sales analysis metric view with customer segmentation
  
  joins:
    - name: customers
      source: dab_lacrosse_dev.02_silver.dim_customers
      on: source.customer_id = customers.customer_id AND customers.__END_AT IS NULL
  
  dimensions:
    - name: region
      expr: source.region
      display_name: Region
      comment: Geographic region of the store
      
    - name: category
      expr: source.category
      display_name: Product Category
      comment: Product category
      
    - name: loyalty_tier
      expr: customers.loyalty_tier
      display_name: Loyalty Tier
      comment: Customer loyalty tier (Bronze, Silver, Gold, Platinum)
      synonyms:
        - tier
        - customer tier
        
    - name: customer_state
      expr: customers.state
      display_name: Customer State
      comment: Customer state location
      
    - name: location_type
      expr: source.location_type
      display_name: Store Location Type
      comment: Type of store location (Downtown, Suburban, Mall)
      
    - name: transaction_month
      expr: source.transaction_month
      display_name: Transaction Month
      comment: Month of transaction
      
    - name: transaction_year
      expr: source.transaction_year
      display_name: Transaction Year
      comment: Year of transaction
      
    - name: payment_method
      expr: source.payment_method
      display_name: Payment Method
      comment: Payment method used
      
  measures:
    - name: total_revenue
      expr: SUM(source.total_amount)
      display_name: Total Revenue
      comment: Sum of all transaction amounts
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
        - sales count
        
    - name: avg_transaction_value
      expr: MEASURE(total_revenue) / MEASURE(transaction_count)
      display_name: Average Transaction Value
      comment: Average revenue per transaction
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      synonyms:
        - aov
        - average order value
        
    - name: total_units_sold
      expr: SUM(source.quantity)
      display_name: Total Units Sold
      comment: Total quantity of products sold
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
          
    - name: unique_customers
      expr: COUNT(DISTINCT source.customer_id)
      display_name: Unique Customers
      comment: Number of unique customers
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
          
    - name: avg_discount_pct
      expr: AVG(source.discount_percentage)
      display_name: Average Discount %
      comment: Average discount percentage applied
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 1
$$;
