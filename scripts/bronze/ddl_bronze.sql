/*
=================================================================================
DDL script : Create Bronze Tables
Script Purpose:
	This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
=================================================================================
*/

USE bigbasket_DB;
GO

/*
=====================================================
TABLE 1: bronze.cst
=====================================================
*/
IF OBJECT_ID('bronze.cst', 'U') IS NOT NULL 
    DROP TABLE bronze.cst;
GO

CREATE TABLE bronze.cst (
    cst_id BIGINT,
    cst_name NVARCHAR(100),
    cst_email NVARCHAR(100),
    cst_phone NVARCHAR(15),
    cst_address NVARCHAR(500),
    cst_area NVARCHAR(100),
    cst_pincode NVARCHAR(10),
    cst_reg_date DATE
);
GO
/*
=====================================================
TABLE 2: bronze.orders
=====================================================
*/
IF OBJECT_ID('bronze.orders', 'U') IS NOT NULL 
    DROP TABLE bronze.orders;
GO

CREATE TABLE bronze.orders (
    order_id BIGINT,
    cst_id INT,
    order_date DATETIME2,
    promised_time DATETIME2,
    actual_time DATETIME2,
    order_total DECIMAL(10,2),
    payment_method NVARCHAR(30),
    delivery_partner_id INT,
    store_id INT
);
GO
/*
=====================================================
TABLE 3: bronze.order_items
=====================================================
*/
IF OBJECT_ID('bronze.order_items', 'U') IS NOT NULL 
    DROP TABLE bronze.order_items;
GO

CREATE TABLE bronze.order_items (
    order_id BIGINT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2)
);
GO
/*
=====================================================
TABLE 4: bronze.products
=====================================================
*/
IF OBJECT_ID('bronze.products', 'U') IS NOT NULL 
    DROP TABLE bronze.products;
GO

CREATE TABLE bronze.products (
    product_id INT,
    product_name NVARCHAR(100),
    category NVARCHAR(100),
    brand NVARCHAR(100),
    price DECIMAL(10,2),
    mrp DECIMAL(10,2),
    margin_percentage INT,
    shelf_life_days INT,
    min_stock_level INT,
    max_stock_level INT
);
GO
/*
=====================================================
TABLE 5: bronze.delivery
=====================================================
*/
IF OBJECT_ID('bronze.delivery', 'U') IS NOT NULL 
    DROP TABLE bronze.delivery;
GO

CREATE TABLE bronze.delivery (
    order_id BIGINT,
    delivery_partner_id INT,
    distance_km DECIMAL(5,2)
);
GO
/*
=====================================================
TABLE 6: bronze.feedback
=====================================================
*/
IF OBJECT_ID('bronze.feedback', 'U') IS NOT NULL 
    DROP TABLE bronze.feedback;
GO

CREATE TABLE bronze.feedback (
    feedback_id INT,
    order_id BIGINT,
    cst_id INT,
    rating INT,
    feedback_category NVARCHAR(50),
    sentiment NVARCHAR(20),
    feedback_date DATE
);
GO
/*
=====================================================
TABLE 7: bronze.marketing
=====================================================
*/
IF OBJECT_ID('bronze.marketing', 'U') IS NOT NULL 
    DROP TABLE bronze.marketing;
GO

CREATE TABLE bronze.marketing (
    campaign_id INT,
    campaign_name NVARCHAR(100),
    campaign_date DATE,
    target_audience NVARCHAR(50),
    channel NVARCHAR(50),
    impressions INT,
    clicks INT,
    conversions INT,
    spend DECIMAL(10,2),
    revenue DECIMAL(10,2)
);
GO
