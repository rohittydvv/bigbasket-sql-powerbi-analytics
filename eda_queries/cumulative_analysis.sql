/*
======================================================================================
Exploratory Data Analysis - Cumulative Analysis
======================================================================================
Script Purpose:
    This script calculates cumulative metrics, rolling totals, and retention metrics
    over periods to understand business growth and customer engagement over time.
    
Usage Notes:
    - Use to evaluate long-term trends and cohort performance.
======================================================================================
*/

-- Cumulative revenue over time by month
SELECT 
    order_year,
    order_month,
    SUM(order_total) AS monthly_revenue,
    SUM(SUM(order_total)) OVER (ORDER BY order_year, order_month) AS cumulative_revenue
FROM gold.fact_orders
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- Customer acquisition cohort analysis: customers by registration month and count of returning orders
WITH cohorts AS (
  SELECT
    c.cst_id,
    DATEFROMPARTS(YEAR(c.cst_reg_date), MONTH(c.cst_reg_date), 1) AS cohort_month,
    DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS order_month
  FROM gold.dim_customers c
  LEFT JOIN gold.fact_orders o ON c.cst_id = o.cst_id
    AND o.order_date >= c.cst_reg_date
)
SELECT
  cohort_month,
  order_month,
  COUNT(DISTINCT cst_id) AS active_customers
FROM cohorts
WHERE order_month IS NOT NULL
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month;

-- Running total of orders per day
SELECT
    order_date,
    COUNT(order_id) AS daily_orders,
    SUM(COUNT(order_id)) OVER (ORDER BY order_date) AS running_order_total
FROM (
    SELECT DISTINCT order_id, CAST(order_date AS DATE) AS order_date
    FROM gold.fact_orders
) AS daily_orders_data
GROUP BY order_date
ORDER BY order_date;