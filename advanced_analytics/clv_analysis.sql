/*
===============================================================================
Advanced Analysis - Customer Lifetime Value (CLV)
===============================================================================
Script Purpose:
    This script estimates the lifetime value of customers based on their historical
    order behavior.
===============================================================================
*/

-- Calculate CLV for each customer
SELECT
  cst_id,
  SUM(order_total) AS lifetime_value,
  COUNT(order_id) AS total_orders,
  CAST (MIN(order_date) AS DATE) AS first_order_date,
  CAST (MAX(order_date) AS DATE) AS last_order_date
FROM gold.fact_orders
GROUP BY cst_id
ORDER BY lifetime_value DESC;

-- Average CLV by payment method
SELECT
  payment_method,
  AVG(lifetime_value) AS avg_clv
FROM (
  SELECT cst_id, payment_method, SUM(order_total) AS lifetime_value
  FROM gold.fact_orders
  GROUP BY cst_id, payment_method
) clv_table
GROUP BY payment_method
ORDER BY avg_clv DESC;

-- CLV by customer tenure segment
WITH customer_clv AS (
    SELECT 
        c.cst_id,
        c.cst_tenure_months,
        SUM(o.order_total) AS lifetime_value
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_orders o
        ON c.cst_id = o.cst_id
    GROUP BY 
        c.cst_id,
        c.cst_tenure_months
),
segment_clv AS (
    SELECT
        CASE 
            WHEN cst_tenure_months <= 12 THEN 'New'
            WHEN cst_tenure_months BETWEEN 12 AND 24 THEN 'Established'
            ELSE 'Loyal'
        END AS tenure_segment,
        lifetime_value
    FROM customer_clv
)
SELECT
    tenure_segment,
    AVG(lifetime_value) AS avg_segment_clv
FROM segment_clv
GROUP BY tenure_segment
ORDER BY avg_segment_clv DESC;