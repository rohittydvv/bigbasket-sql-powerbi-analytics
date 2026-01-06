/*
===============================================================================
Advanced Analysis - Marketing Campaign Performance
===============================================================================
Script Purpose:
    This script provides deep insights into marketing campaign performance,
    channel effectiveness and ROI trends.
    Queries are designed to evaluate spending efficiency by week day and 
    summarize key metrics for all channels, enabling strategic optimizations.
===============================================================================
*/

-- Marketing ROI by campaign weekday
SELECT
  DATEPART(WEEKDAY, m.campaign_date) AS campaign_weekday,
  AVG(CASE WHEN m.spend > 0 THEN m.revenue/m.spend ELSE NULL END) AS avg_roi
FROM gold.fact_marketing m
GROUP BY DATEPART(WEEKDAY, m.campaign_date)
ORDER BY avg_roi DESC;


-- Channel-level performance summary
    SELECT
    channel,
    COUNT(DISTINCT campaign_id) AS campaigns_count,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    SUM(spend) AS total_spend,
    SUM(revenue) AS total_revenue,
    CASE 
        WHEN SUM(impressions) > 0 
        THEN SUM(clicks) * 100.0 / SUM(impressions)
        ELSE NULL
    END AS ctr, -- CTR 

    CASE 
        WHEN SUM(clicks) > 0 
        THEN SUM(conversions) * 100.0 / SUM(clicks)
        ELSE NULL
    END AS conversion_rate, -- Conversion Rate

    CASE 
        WHEN SUM(spend) > 0 
        THEN (SUM(revenue) - SUM(spend)) * 100.0 / SUM(spend)
        ELSE NULL
    END AS roi, -- ROI

    CASE 
        WHEN SUM(clicks) > 0 
        THEN SUM(spend) / SUM(clicks)
        ELSE NULL
    END AS cost_per_click, -- Cost per Click

    CASE 
        WHEN SUM(conversions) > 0 
        THEN SUM(spend) / SUM(conversions)
        ELSE NULL
    END AS cost_per_conversion, -- Cost per Conversion

    CASE 
        WHEN SUM(conversions) > 0 
        THEN SUM(revenue) / SUM(conversions)
        ELSE NULL
    END AS revenue_per_conversion -- Revenue per Conversion

FROM gold.fact_marketing
GROUP BY channel
ORDER BY roi DESC;
