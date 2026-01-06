/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
   -This script creates views for the Gold layer in the data warehouse. 
   -The Gold layer represents the final dimension and fact tables (Star Schema)
   -Each view combines data from the Silver layer to produce a clean,
    enriched and business-ready dataset.
=============================================================================
*/

USE bigbasket_DB;
GO
/*
=============================================================================
Create Dimension: gold.dim_customers
=============================================================================
*/
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
    cst_id,
    cst_name,
    cst_email,
    cst_area,
    cst_pincode,
    cst_reg_date,
    DATEDIFF(MONTH, cst_reg_date, GETDATE()) AS cst_tenure_months
FROM silver.cst;
GO
/*
=============================================================================
Create Dimension: gold.dim_products
=============================================================================
*/
CREATE OR ALTER VIEW gold.dim_products AS
SELECT
    product_id,
    product_name,
    category,
    brand,
    price,
    mrp,
    margin_percentage,
    shelf_life_days
FROM silver.products;
GO
/*
=============================================================================
Create Dimension: gold.dim_delivery_partners
=============================================================================
*/
CREATE OR ALTER VIEW gold.dim_delivery_partners AS
SELECT DISTINCT
    delivery_partner_id
FROM silver.orders
WHERE delivery_partner_id IS NOT NULL;
GO
/*
=============================================================================
Create Dimension: gold.dim_campaigns
=============================================================================
*/
CREATE OR ALTER VIEW gold.dim_campaigns AS
SELECT DISTINCT
    campaign_id,
    campaign_name,
    campaign_date,
    target_audience,
    channel
FROM silver.marketing;
GO
/*
=============================================================================
Create Fact Table: gold.fact_orders
=============================================================================
*/
CREATE OR ALTER VIEW gold.fact_orders AS
SELECT
    o.order_id,
    o.cst_id,
    c.cst_name,
    c.cst_area,
    c.cst_pincode,
    o.order_date,
    o.promised_time,
    o.actual_time,
    o.order_total,
    o.payment_method,
    o.delivery_partner_id,
    o.store_id,
    o.order_year,
    o.order_month,
    o.order_quarter,
    o.order_day_of_week,
    o.order_hour,
    o.delivery_time_minutes,
    o.delivery_delay_minutes,
    o.delivery_status
FROM silver.orders o
INNER JOIN gold.dim_customers c ON o.cst_id = c.cst_id;
GO
/*
=============================================================================
Create Fact Table: gold.fact_order_items
=============================================================================
*/
CREATE OR ALTER VIEW gold.fact_order_items AS
SELECT
    oi.order_id,
    oi.product_id,
    p.product_name,
    p.category,
    p.brand,
    oi.quantity,
    oi.unit_price,
    oi.line_total
FROM silver.order_items oi
INNER JOIN gold.dim_products p ON oi.product_id = p.product_id;
GO
/*
=============================================================================
Create Fact Table: gold.fact_feedback
=============================================================================
*/
CREATE OR ALTER VIEW gold.fact_feedback AS
SELECT
    f.feedback_id,
    f.order_id,
    f.cst_id,
    c.cst_name,
    f.rating,
    f.feedback_category,
    f.sentiment,
    f.feedback_date
FROM silver.feedback f
INNER JOIN gold.dim_customers c ON f.cst_id = c.cst_id;
GO
/*
=============================================================================
Create Fact Table: gold.fact_marketing
=============================================================================
*/
CREATE OR ALTER VIEW gold.fact_marketing AS
SELECT
    m.campaign_id,
    m.campaign_name,
    m.campaign_date,
    m.target_audience,
    m.channel,
    m.impressions,
    m.clicks,
    m.conversions,
    m.spend,
    m.revenue,
    m.ctr,
    m.conversion_rate,
    m.roi,
    m.cost_per_click,
    m.cost_per_conversion,
    m.revenue_per_conversion
FROM silver.marketing m;
GO