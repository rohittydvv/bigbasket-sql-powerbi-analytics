/*
===============================================================================
Advanced Analysis - Delivery Optimization
===============================================================================
Script Purpose:
    This script assesses delivery efficiency, routes and partner performance to
    identify cost reduction and service improvement opportunities.
===============================================================================
*/

-- Average delivery time by distance bucket
SELECT
  CASE 
    WHEN distance_km <= 2 THEN '0-2km'
    WHEN distance_km < 5 THEN '2-4km'
    WHEN distance_km >= 5 THEN '5km+'
    ELSE 'Unknown'
  END AS distance_bucket,
  AVG(o.delivery_time_minutes) AS avg_delivery_time
FROM gold.fact_orders o
JOIN silver.delivery d ON o.order_id = d.order_id
GROUP BY CASE 
    WHEN distance_km <= 2 THEN '0-2km'
    WHEN distance_km < 5 THEN '2-4km'
    WHEN distance_km >= 5 THEN '5km+'
    ELSE 'Unknown'
  END;

-- Delivery partner performance (on-time rate and avg delay)
SELECT
  delivery_partner_id,
  SUM(CASE WHEN delivery_status IN ('On Time', 'Early') THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS on_time_percentage,
  AVG(delivery_delay_minutes) AS avg_delay_minutes
FROM gold.fact_orders
GROUP BY delivery_partner_id
ORDER BY on_time_percentage DESC, avg_delay_minutes ASC;
