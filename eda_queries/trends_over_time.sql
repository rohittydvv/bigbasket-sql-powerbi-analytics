/*
===============================================================================
Exploratory Data Analysis - Trends Over Time
===============================================================================
Script Purpose:
    This script analyzes business performance and customer behavior trends over time,
    such as monthly revenue, customer acquisition and order volume patterns.
    
Usage Notes:
    - Use trend analysis to forecast and monitor business health.
===============================================================================
*/

-- Monthly new customer registrations
SELECT 
    YEAR (cst_reg_date) AS reg_year,
    MONTH (cst_reg_date) AS reg_month,
    COUNT(*) AS new_customers
FROM gold.dim_customers
GROUP BY YEAR (cst_reg_date), MONTH (cst_reg_date)
ORDER BY reg_year, reg_month;

-- Monthly total revenue
SELECT 
    order_year,
    order_month,
    SUM(order_total) AS total_revenue
FROM gold.fact_orders
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- Monthly total orders
SELECT 
    order_year,
    order_month,
    COUNT(DISTINCT order_id) AS total_orders
FROM gold.fact_orders
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- Average order value (AOV) per month
SELECT 
    order_year,
    order_month,
    AVG(order_total) AS avg_order_value
FROM gold.fact_orders
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- Monthly marketing spend and revenue
SELECT
    YEAR(campaign_date) AS campaign_year,
    MONTH(campaign_date) AS campaign_month,
    SUM(spend) AS total_spend,
    SUM(revenue) AS total_revenue
FROM gold.fact_marketing
GROUP BY YEAR(campaign_date),MONTH(campaign_date)
ORDER BY campaign_year,campaign_month;
