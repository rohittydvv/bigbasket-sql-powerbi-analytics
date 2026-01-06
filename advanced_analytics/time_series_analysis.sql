/*
===============================================================================
Advanced Analysis - Time Series & Trend Analysis
===============================================================================
Script Purpose:
    This script analyzes business data over time for seasonality, growth rates,
    and moving averages to support forecasting and planning decisions.
===============================================================================
*/

-- Month-over-month (MoM) revenue growth %
WITH monthly_revenue AS (
  SELECT
    order_year,
    order_month,
    SUM(order_total) AS revenue
  FROM gold.fact_orders
  GROUP BY order_year, order_month
)
SELECT
  order_year,
  order_month,
  revenue,
  LAG(revenue) OVER (ORDER BY order_year, order_month) AS prev_month_revenue,
  CASE 
    WHEN LAG(revenue) OVER (ORDER BY order_year, order_month) > 0
    THEN (revenue - LAG(revenue) OVER (ORDER BY order_year, order_month)) * 100.0 
          / LAG(revenue) OVER (ORDER BY order_year, order_month)
    ELSE NULL 
  END AS mom_growth_percent
FROM monthly_revenue
ORDER BY order_year, order_month;

-- Year-over-year (YoY) revenue growth %
WITH yearly_revenue AS (
  SELECT
    order_year,
    SUM(order_total) AS revenue
  FROM gold.fact_orders
  GROUP BY order_year
)
SELECT
  order_year,
  revenue,
  LAG(revenue) OVER (ORDER BY order_year) AS prev_year_revenue,
  CASE
    WHEN LAG(revenue) OVER (ORDER BY order_year) > 0
    THEN (revenue - LAG(revenue) OVER (ORDER BY order_year)) * 100.0 
          / LAG(revenue) OVER (ORDER BY order_year)
    ELSE NULL
  END AS yoy_growth_percent
FROM yearly_revenue
ORDER BY order_year;

-- Detect peak day of week by number of orders
SELECT
  order_day_of_week,
  COUNT(DISTINCT order_id) AS order_count
FROM gold.fact_orders
GROUP BY order_day_of_week
ORDER BY order_count DESC;

-- Detect peak hour of day by number of orders
SELECT
  order_hour,
  COUNT(DISTINCT order_id) AS order_count
FROM gold.fact_orders
GROUP BY order_hour
ORDER BY order_count DESC;

-- Compare total orders on weekdays vs weekends
SELECT
  CASE 
    WHEN order_day_of_week IN ('Saturday', 'Sunday') THEN 'Weekend'
    ELSE 'Weekday'
  END AS day_type,
  COUNT(DISTINCT order_id) AS order_count
FROM gold.fact_orders
GROUP BY CASE 
           WHEN order_day_of_week IN ('Saturday', 'Sunday') THEN 'Weekend'
           ELSE 'Weekday'
         END;
