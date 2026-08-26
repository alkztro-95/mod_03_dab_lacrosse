-- Gold Layer: Customer Analytics Metric View
-- Semantic layer for customer-centric metrics
-- Uses SCD2 dim_customers (current records only) joined with fact_sales

CREATE OR REPLACE VIEW dab_lacrosse_dev.03_gold.mv_customer_analytics
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  
  source: dab_lacrosse_dev.03_gold.gold_dim_customers
  
  filter: __END_AT IS NULL
  
  comment: Customer analytics metric view with lifetime value and transaction metrics
  
  joins:
    - name: sales
      source: dab_lacrosse_dev.03_gold.gold_fact_sales
      on: source.customer_id = sales.customer_id
  
  dimensions:
    - name: loyalty_tier
      expr: source.loyalty_tier
      display_name: Loyalty Tier
      comment: Customer loyalty tier (Bronze, Silver, Gold, Platinum)
      synonyms:
        - tier
        - customer segment
        
    - name: state
      expr: source.state
      display_name: Customer State
      comment: State where customer is located
      synonyms:
        - location
        - customer location
        
    - name: city
      expr: source.city
      display_name: Customer City
      comment: City where customer is located
      
    - name: customer_name
      expr: CONCAT(source.first_name, ' ', source.last_name)
      display_name: Customer Name
      comment: Full name of the customer
      
  measures:
    - name: customer_count
      expr: COUNT(DISTINCT source.customer_id)
      display_name: Customer Count
      comment: Total number of customers
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
      synonyms:
        - total customers
        - number of customers
        
    - name: total_lifetime_value
      expr: SUM(sales.total_amount)
      display_name: Total Lifetime Value
      comment: Total revenue from all customer transactions
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      synonyms:
        - clv
        - customer lifetime value
        - total revenue
        
    - name: avg_lifetime_value
      expr: MEASURE(total_lifetime_value) / MEASURE(customer_count)
      display_name: Average Lifetime Value
      comment: Average revenue per customer
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      synonyms:
        - avg clv
        - average customer value
        
    - name: total_transactions
      expr: COUNT(sales.transaction_id)
      display_name: Total Transactions
      comment: Total number of transactions across all customers
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
      synonyms:
        - transaction count
        - order count
        
    - name: avg_transactions_per_customer
      expr: MEASURE(total_transactions) / MEASURE(customer_count)
      display_name: Avg Transactions per Customer
      comment: Average number of transactions per customer
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
      synonyms:
        - purchase frequency
        - orders per customer
        
    - name: avg_transaction_value
      expr: MEASURE(total_lifetime_value) / MEASURE(total_transactions)
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
        - average order value
$$;
