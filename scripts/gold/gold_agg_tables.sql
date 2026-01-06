/*
=============================================================================================
DDL Script: Create Gold Aggregation Tables
=============================================================================================
Script Purpose:
    -This script creates aggregated tables for the Gold layer in the data warehouse.
    -These tables provide pre-computed, summary-level metrics to accelerate
     analytics and reporting workflows, reducing query complexity and improving performance.
=============================================================================================
*/

USE bigbasket_DB;
GO
/*
=====================================================
TABLE 1: gold.agg_customer_rfm (CUSTOMER RFM)
=====================================================
*/
--Creating table
IF OBJECT_ID('gold.agg_customer_rfm', 'U') IS NOT NULL 
    DROP TABLE gold.agg_customer_rfm;
GO
CREATE TABLE gold.agg_customer_rfm (
    cst_id INT PRIMARY KEY,
    recency_days INT,
    frequency INT,
    monetary DECIMAL(18,2)
);
--Inserting data
INSERT INTO gold.agg_customer_rfm
(cst_id, recency_days, frequency, monetary)
SELECT
    cst_id,
    DATEDIFF(DAY, MAX(order_date), GETDATE()) AS recency_days,
    COUNT(order_id) AS frequency,
    SUM(order_total) AS monetary
FROM silver.orders
GROUP BY cst_id;
GO
/*
=====================================================
TABLE 2: gold.agg_product_performance
=====================================================
*/
--Creating table
IF OBJECT_ID('gold.agg_product_performance', 'U') IS NOT NULL 
    DROP TABLE gold.agg_product_performance;
GO
CREATE TABLE gold.agg_product_performance (
    product_id INT PRIMARY KEY,
    total_quantity INT,
    total_revenue DECIMAL(18,2),
    avg_unit_price DECIMAL(18,2)
);
--Inserting data
INSERT INTO gold.agg_product_performance
(product_id, total_quantity, total_revenue, avg_unit_price)
SELECT
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(line_total) AS total_revenue,
    AVG(unit_price) AS avg_unit_price
FROM silver.order_items
GROUP BY product_id;
GO
/*
=====================================================
TABLE 3: gold.agg_daily_sales
=====================================================
*/
--Creating table
IF OBJECT_ID('gold.agg_daily_sales', 'U') IS NOT NULL 
    DROP TABLE gold.agg_daily_sales;
GO
CREATE TABLE gold.agg_daily_sales (
    order_date DATE PRIMARY KEY,
    total_orders INT,
    total_revenue DECIMAL(20,2),
    avg_order_value DECIMAL(20,2)
);
--Inserting data
INSERT INTO gold.agg_daily_sales
(order_date, total_orders, total_revenue, avg_order_value)
SELECT
    CAST(order_date AS DATE) AS order_date,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(order_total) AS total_revenue,
    AVG(order_total) AS avg_order_value
FROM silver.orders
GROUP BY CAST(order_date AS DATE);
GO