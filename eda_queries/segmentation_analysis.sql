/*
============================================================================================
Exploratory Data Analysis - Segmentation Analysis
============================================================================================
Script Purpose:
    This script segments customers, products and other entities into meaningful groups 
    based on behavior, demographics or performance to enable targeted strategies.
    
Usage Notes:
    - Supports marketing campaign targeting, product prioritization and customer success.
============================================================================================
*/

-- Customer segmentation by RFM scores
WITH rfm_scores AS (
  SELECT 
    c.cst_id,
    DATEDIFF(DAY, MAX(o.order_date), GETDATE()) AS recency,
    COUNT(o.order_id) AS frequency,
    SUM(o.order_total) AS monetary
  FROM gold.dim_customers c
  LEFT JOIN gold.fact_orders o ON c.cst_id = o.cst_id
  GROUP BY c.cst_id
)
SELECT
  cst_id,
  NTILE(5) OVER (ORDER BY recency ASC) AS recency_score,
  NTILE(5) OVER (ORDER BY frequency DESC) AS frequency_score,
  NTILE(5) OVER (ORDER BY monetary DESC) AS monetary_score
FROM rfm_scores
WHERE recency IS NOT NULL AND monetary IS NOT NULL;

-- Product segmentation by sales volume (top, medium, low)
SELECT
  p.product_id,
  p.product_name,
  SUM(oi.quantity) AS total_quantity,
  CASE 
    WHEN SUM(oi.quantity) >= 60 THEN 'Top Selling'
    WHEN SUM(oi.quantity) BETWEEN 39 AND 59 THEN 'Medium Selling'
    ELSE 'Low Selling'
  END AS sales_segment
FROM gold.dim_products p
LEFT JOIN gold.fact_order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

-- Customer segmentation by tenure (months since registration)
SELECT
  cst_id,
  cst_tenure_months,
  CASE 
    WHEN cst_tenure_months <= 12 THEN 'New'
    WHEN cst_tenure_months BETWEEN 12 AND 24 THEN 'Established'
    ELSE 'Loyal'
  END AS tenure_segment
FROM gold.dim_customers;