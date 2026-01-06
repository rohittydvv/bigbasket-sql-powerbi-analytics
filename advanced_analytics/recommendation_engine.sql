/*
===============================================================================
Advanced Analysis - Product Recommendation Engine
===============================================================================
Script Purpose:
    These queries identify products with high demand as well as high margin &
    customer segment affinities.
===============================================================================
*/

-- High demand + high margin products
WITH product_sales AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS total_quantity_sold,
        SUM(oi.line_total) AS total_revenue
    FROM gold.fact_order_items oi
    GROUP BY oi.product_id
)
SELECT TOP 20
    p.product_id,
    p.product_name,
    p.category,
    p.margin_percentage,
    p.profit_per_unit,
    ps.total_quantity_sold,
    ps.total_revenue,
    (ps.total_quantity_sold * p.profit_per_unit) AS total_profit_estimated
FROM product_sales ps
LEFT JOIN silver.products p
    ON ps.product_id = p.product_id
WHERE 
    ps.total_quantity_sold >= 50          -- demand threshold (tune for your data)
    AND p.margin_percentage >= 20         -- margin threshold (tune for your data)
ORDER BY 
    total_profit_estimated DESC;

-- Recommend categories for a target customer segment (e.g., "Loyal" by tenure)
SELECT
  p.category,
  COUNT(*) AS segment_purchases
FROM gold.fact_order_items oi
LEFT JOIN gold.fact_orders o ON oi.order_id = o.order_id
LEFT JOIN gold.dim_products p ON oi.product_id = p.product_id
LEFT JOIN gold.dim_customers c ON o.cst_id = c.cst_id
WHERE c.cst_tenure_months > 24 -- using "Loyal" as example (Change according to the needs)
GROUP BY p.category
ORDER BY segment_purchases DESC;