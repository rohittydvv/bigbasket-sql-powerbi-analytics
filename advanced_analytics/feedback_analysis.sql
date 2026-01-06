/*
===============================================================================
Advanced Analysis - Feedback
===============================================================================
Script Purpose:
    This script investigates customer feedback to uncover actionable insights into
    service quality, product performance and operational efficiency. 
    Analysis includes correlating feedback metrics with delivery delays and
    identifying products most affected by negative ratings, 
    helping to prioritize quality improvement and retention efforts.
===============================================================================
*/

-- Correlate average feedback rating to delivery delay buckets
SELECT
  CASE 
    WHEN o.delivery_delay_minutes <= 0 THEN 'Early/On time'
    WHEN o.delivery_delay_minutes BETWEEN 1 AND 5 THEN 'Minor delay'
    ELSE 'Major delay'
  END AS delay_segment,
  AVG(f.rating) AS avg_rating,
  COUNT(*) AS feedback_count
FROM gold.fact_feedback f
LEFT JOIN gold.fact_orders o ON f.order_id = o.order_id
GROUP BY 
  CASE 
    WHEN o.delivery_delay_minutes <= 0 THEN 'Early/On time'
    WHEN o.delivery_delay_minutes BETWEEN 1 AND 5 THEN 'Minor delay'
    ELSE 'Major delay'
  END
ORDER BY avg_rating DESC;


-- Products with highest share of negative feedback
SELECT
  p.product_id,
  p.product_name,
  COUNT(f.feedback_id) AS total_feedback,
  SUM(CASE WHEN f.sentiment = 'Negative' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.feedback_id) AS negative_feedback_perc
FROM gold.fact_feedback f
LEFT JOIN gold.fact_order_items oi ON f.order_id = oi.order_id
LEFT JOIN gold.dim_products p ON oi.product_id = p.product_id
WHERE feedback_category = 'product quality'
GROUP BY p.product_id, p.product_name
ORDER BY negative_feedback_perc DESC;