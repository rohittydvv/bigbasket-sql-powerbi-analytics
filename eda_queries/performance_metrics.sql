/*
===============================================================================
Exploratory Data Analysis - Performance Metrics
===============================================================================
Script Purpose:
    This script calculates key performance indicators such as totals, averages
    and rates across customers, products, orders, delivery, marketing and 
    feedback data. Metrics provide a snapshot of business health and efficiency.
    
Usage Notes:
    - Query the gold layer for business-wide insights.
===============================================================================
*/

-- Total customers in system
SELECT COUNT(DISTINCT cst_id) AS total_customers
FROM gold.dim_customers;

-- Total products available
SELECT COUNT(DISTINCT product_id) AS total_products
FROM gold.dim_products;

-- Total orders placed
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM gold.fact_orders;

-- Total revenue generated
SELECT SUM(order_total) AS total_revenue
FROM gold.fact_orders;

-- Average order value (AOV)
SELECT AVG(order_total) AS avg_order_value
FROM gold.fact_orders
WHERE order_total IS NOT NULL;

-- On-time delivery rate (%)
SELECT 
  SUM(CASE WHEN delivery_status IN ('On Time','Early') THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS on_time_percentage
FROM gold.fact_orders;

-- Overall marketing ROI
SELECT 
  CASE WHEN SUM(spend) > 0 THEN SUM(revenue) / SUM(spend) ELSE NULL END AS overall_roi
FROM gold.fact_marketing;

-- Average customer rating
SELECT AVG(CAST(rating AS FLOAT)) AS avg_rating
FROM gold.fact_feedback
WHERE rating IS NOT NULL;