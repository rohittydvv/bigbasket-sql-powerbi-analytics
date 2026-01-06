/*
===============================================================================
Exploratory Data Analysis - Ranking Analysis
===============================================================================
Script Purpose:
    This script ranks customers, products, and campaigns by metrics such as 
    revenue, frequency, ratings, and ROI to identify top performers and priority targets.
    
Usage Notes:
    - Use rankings for targeting marketing and prioritizing products or customers.
===============================================================================
*/

-- Top 10 customers by total spending
SELECT TOP 10
    cst_id,
    SUM(order_total) AS total_spent
FROM gold.fact_orders
GROUP BY cst_id
ORDER BY total_spent DESC;

-- Top 10 products by revenue
SELECT TOP 10
    p.product_id,
    p.product_name,
    SUM(oi.line_total) AS total_revenue
FROM gold.fact_order_items oi
JOIN gold.dim_products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

-- Top 5 marketing campaigns by ROI
SELECT TOP 5
    campaign_id,
    campaign_name,
    CASE WHEN SUM(spend)>0 THEN SUM(revenue)/SUM(spend) ELSE NULL END AS roi
FROM gold.fact_marketing
GROUP BY campaign_id, campaign_name
ORDER BY roi DESC;

-- Top 10 customers by frequency (number of orders)
SELECT TOP 10
    cst_id,
    COUNT(order_id) AS order_count
FROM gold.fact_orders
GROUP BY cst_id
ORDER BY order_count DESC;

-- Top 5 delivery partners by average delivery delay (ascending)
SELECT TOP 5
    dp.delivery_partner_id,
    AVG(o.delivery_delay_minutes) AS avg_delay
FROM gold.fact_orders o
JOIN gold.dim_delivery_partners dp ON o.delivery_partner_id = dp.delivery_partner_id
GROUP BY dp.delivery_partner_id
ORDER BY avg_delay ASC;