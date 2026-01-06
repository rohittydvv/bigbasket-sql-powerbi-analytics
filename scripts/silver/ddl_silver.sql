/*
=================================================================================
DDL script: Create Silver Tables
Script Purpose:
    Creates cleaned and typed tables in 'silver' schema with proper data types,
    derived columns and preparation for constraints.
=================================================================================
*/

USE bigbasket_DB;
GO
/*
==============================================================
Dropping Existing Silver Tables (Respecting FK Dependencies)
==============================================================
*/
IF OBJECT_ID('silver.feedback', 'U') IS NOT NULL DROP TABLE silver.feedback;
GO
IF OBJECT_ID('silver.delivery', 'U') IS NOT NULL DROP TABLE silver.delivery;
GO
IF OBJECT_ID('silver.order_items', 'U') IS NOT NULL DROP TABLE silver.order_items;
GO
IF OBJECT_ID('silver.orders', 'U') IS NOT NULL DROP TABLE silver.orders;
GO
IF OBJECT_ID('silver.marketing', 'U') IS NOT NULL DROP TABLE silver.marketing;
GO
IF OBJECT_ID('silver.products', 'U') IS NOT NULL DROP TABLE silver.products;
GO
IF OBJECT_ID('silver.cst', 'U') IS NOT NULL DROP TABLE silver.cst;
GO
/*
=====================================================
TABLE 1: silver.cst (Customers)
=====================================================
*/
CREATE TABLE silver.cst (
    -- Original columns
    cst_id             INT NOT NULL,
    cst_name           NVARCHAR(100),
    cst_email          NVARCHAR(100),
    cst_phone          NVARCHAR(15),
    cst_address        NVARCHAR(500),
    cst_area           NVARCHAR(100),
    cst_pincode        NVARCHAR(10),
    cst_reg_date       DATE,

    -- Metadata
    dwh_create_date    DATETIME2 DEFAULT GETDATE()

    -- Primary Key
    CONSTRAINT PK_cst PRIMARY KEY CLUSTERED (cst_id)
);
GO
/*
=====================================================
TABLE 2: silver.orders
=====================================================
*/
CREATE TABLE silver.orders (
    -- Original columns
    order_id               BIGINT NOT NULL,
    cst_id                 INT,
    order_date             DATETIME2,
    promised_time          DATETIME2,
    actual_time            DATETIME2,
    order_total           DECIMAL(10,2),
    payment_method         NVARCHAR(30),
    delivery_partner_id    INT,
    store_id               INT,
    
    -- Derived columns
    order_year             INT,
    order_month            INT,
    order_quarter          INT,
    order_day_of_week      NVARCHAR(20),
    order_hour             INT,
    delivery_time_minutes  INT,
    delivery_delay_minutes INT,
    delivery_status        NVARCHAR(50),
    
    -- Metadata
    dwh_create_date        DATETIME2 DEFAULT GETDATE()
    
    -- Primary Key
    CONSTRAINT PK_orders PRIMARY KEY CLUSTERED (order_id),
    
    -- Foreign Keys
    CONSTRAINT FK_orders_cst FOREIGN KEY (cst_id) 
        REFERENCES silver.cst(cst_id)
);
GO
/*
=====================================================
TABLE 4: silver.products
=====================================================
*/
CREATE TABLE silver.products (
    -- Original columns
    product_id          INT NOT NULL,
    product_name        NVARCHAR(100),
    category            NVARCHAR(100),
    brand               NVARCHAR(100),
    price               DECIMAL(10,2),
    mrp                 DECIMAL(10,2),
    margin_percentage   INT,
    shelf_life_days     INT,
    min_stock_level     INT,
    max_stock_level     INT,
    
    -- Derived columns
    discount_amount     DECIMAL(10,2),
    discount_percentage DECIMAL(5,2),
    profit_per_unit     DECIMAL(10,2),
    
    -- Metadata
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
    
    -- Primary Key
    CONSTRAINT PK_products PRIMARY KEY CLUSTERED (product_id)
);
GO
/*
=====================================================
TABLE 3: silver.order_items
=====================================================
*/
CREATE TABLE silver.order_items (
    -- Original columns
    order_id        BIGINT NOT NULL,
    product_id      INT NOT NULL,
    quantity        INT,
    unit_price      DECIMAL(10,2),
    
    -- Derived columns
    line_total      DECIMAL(10,2),
    
    -- Metadata
    dwh_create_date DATETIME2 DEFAULT GETDATE()
    
    -- Primary Key (Composite)
    CONSTRAINT PK_order_items PRIMARY KEY CLUSTERED (order_id, product_id),

    --Foreign Keys
    CONSTRAINT FK_order_items_orders FOREIGN KEY (order_id) 
        REFERENCES silver.orders(order_id),

    CONSTRAINT FK_order_items_products FOREIGN KEY (product_id) 
        REFERENCES silver.products(product_id)
);
GO
/*
=====================================================
TABLE 5: silver.delivery
=====================================================
*/
CREATE TABLE silver.delivery (
    -- Original columns
    order_id            BIGINT NOT NULL,
    delivery_partner_id INT,
    distance_km         DECIMAL(5,2),
    
    -- Metadata
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
    
    -- Primary Key
    CONSTRAINT PK_delivery PRIMARY KEY CLUSTERED (order_id),
    
    -- Foreign Key
    CONSTRAINT FK_delivery_orders FOREIGN KEY (order_id) 
        REFERENCES silver.orders(order_id)
);
GO
/*
=====================================================
TABLE 6: silver.feedback
=====================================================
*/
CREATE TABLE silver.feedback (
    -- Original columns
    feedback_id       INT NOT NULL,
    order_id          BIGINT,
    cst_id            INT,
    rating            INT,
    feedback_category NVARCHAR(100),
    sentiment         NVARCHAR(50),
    feedback_date     DATE,
    
    -- Metadata
    dwh_create_date   DATETIME2 DEFAULT GETDATE()
    
    -- Primary Key
    CONSTRAINT PK_feedback PRIMARY KEY CLUSTERED (feedback_id),
    
    -- Foreign Keys
    CONSTRAINT FK_feedback_orders FOREIGN KEY (order_id) 
        REFERENCES silver.orders(order_id),
    CONSTRAINT FK_feedback_cst FOREIGN KEY (cst_id) 
        REFERENCES silver.cst(cst_id)
);
GO
/*
=====================================================
TABLE 7: silver.marketing
=====================================================
*/
CREATE TABLE silver.marketing (
    -- Original columns
    campaign_id            INT NOT NULL,
    campaign_name          NVARCHAR(100),
    campaign_date          DATE,
    target_audience        NVARCHAR(100),
    channel                NVARCHAR(50),
    impressions            INT,
    clicks                 INT,
    conversions            INT,
    spend                  DECIMAL(10,2),
    revenue                DECIMAL(10,2),
    
    -- Derived columns (populated during INSERT)
    ctr                    DECIMAL(10,4),  -- Click-through rate
    conversion_rate        DECIMAL(10,4),  -- Conversion rate
    roi                    DECIMAL(10,4),  -- Return on investment
    cost_per_click         DECIMAL(10,4),  -- CPC
    cost_per_conversion    DECIMAL(10,4),  -- Cost per conversion
    revenue_per_conversion DECIMAL(10,4),  -- Average order value
    
    -- Metadata
    dwh_create_date        DATETIME2 DEFAULT GETDATE()
    
    -- Primary Key
    CONSTRAINT PK_marketing PRIMARY KEY CLUSTERED (campaign_id)
);
GO
