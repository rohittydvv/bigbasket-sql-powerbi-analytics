/*
=================================================================================
DML Script: Load Silver Layer with Transformations
Script Purpose:
    Transform and load data from silver to silver layer with:
    - Data type conversions (IF NEEDED)
    - Text cleaning (TRIM, case standardization)
    - NULL handling
    - Derived column calculations
    - Data validation
=================================================================================
*/
USE bigbasket_DB;
GO

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    SET NOCOUNT ON;

    -- Variables for timing and logging
    DECLARE @TableName NVARCHAR(100);
    DECLARE @StartTime DATETIME2;
    DECLARE @EndTime DATETIME2;
    DECLARE @Duration DECIMAL(10,2);
    DECLARE @TotalStartTime DATETIME2;
    DECLARE @TotalEndTime DATETIME2;
    DECLARE @TotalDuration DECIMAL(10,2);
    
    BEGIN TRY
    BEGIN TRANSACTION;
        -- Delete in reverse dependency order
        PRINT 'Clearing existing data...';
        DELETE FROM silver.feedback;
        DELETE FROM silver.delivery;
        DELETE FROM silver.order_items;
        DELETE FROM silver.orders;
        DELETE FROM silver.marketing;
        DELETE FROM silver.products;
        DELETE FROM silver.cst;

        -- Overall timing
        SET @TotalStartTime = SYSDATETIME();
        PRINT '================================================';
		PRINT 'Loading Silver Layer with Transformations';
		PRINT '================================================';
        
        /*
        =====================================================
        TABLE 1: silver.cst (Customers)
        =====================================================
        */
        SET @TableName = 'silver.cst';
        SET @StartTime = SYSDATETIME();
        PRINT '[1/7] Loading ' + @TableName + '...';

        INSERT INTO silver.cst (
            cst_id,
            cst_name,
            cst_email,
            cst_phone,
            cst_address,
            cst_area,
            cst_pincode,
            cst_reg_date
        )
        SELECT
            cst_id,
            TRIM(cst_name) AS cst_name,
            cst_email,
            cst_phone,
            cst_address,
            cst_area,
            CASE
            WHEN LEN(LTRIM(cst_pincode,'0'))=6 THEN LTRIM(cst_pincode,'0')
            ELSE 'Unkown'
            END AS cst_pincode, --Removing leading zeros & handling invalid pincodes
            cst_reg_date
        FROM bronze.cst
        WHERE cst_id IS NOT NULL

        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT '';
        /*
        =====================================================
        TABLE 2: silver.products
        =====================================================
        */
        SET @TableName = 'silver.products';
        SET @StartTime = SYSDATETIME();
        PRINT '[2/7] Loading ' + @TableName + '...';
        
        INSERT INTO silver.products(
            product_id,
            product_name,
            category,
            brand,
            price,
            mrp,
            margin_percentage,
            shelf_life_days,
            min_stock_level,
            max_stock_level,
            discount_amount,
            discount_percentage,
            profit_per_unit
        )
        SELECT
	        product_id,
	        TRIM(product_name) AS product_name,
	        TRIM(category) AS category,
	        TRIM(brand) AS brand,
	        price,
	        mrp,
	        margin_percentage,
	        shelf_life_days,
	        min_stock_level,
	        max_stock_level,
	        mrp-price AS discount_amount,
	        ((mrp-price)*100/mrp) AS discount_percentage,
	        (price*margin_percentage)/100 AS profit_per_unit
        FROM bronze.products
        WHERE product_id IS NOT NULL;

        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT '';
        /*
        =====================================================
        TABLE 3: silver.marketing
        =====================================================
        */
        SET @TableName = 'silver.marketing';
        SET @StartTime = SYSDATETIME();
        PRINT '[3/7] Loading ' + @TableName + '...';

        INSERT INTO silver.marketing (
            campaign_id,
            campaign_name,
            campaign_date,
            target_audience,
            channel,
            impressions,
            clicks,
            conversions,
            spend,
            revenue,
            -- Derived columns
            ctr,
            conversion_rate,
            roi,
            cost_per_click,
            cost_per_conversion,
            revenue_per_conversion
        )
        SELECT
            campaign_id,
            TRIM(campaign_name),
            campaign_date,
            ISNULL(TRIM(target_audience), 'All') AS target_audience, --Handle NULL values
            ISNULL(TRIM(channel), 'Unknown') AS channel, --Handle NULL values
            impressions,
            clicks,
            conversions,
            spend,
            revenue,
            CASE 
                WHEN impressions>0
                THEN CAST(clicks AS DECIMAL(10,4)) * 100 / impressions
                ELSE NULL
            END AS ctr, --(Click-Through Rate)
            CASE
                WHEN clicks>0 
                THEN CAST(conversions AS DECIMAL(10,4))*100 / clicks
                ELSE NULL
            END AS conversion_rate,
            CASE
                WHEN spend>0
                THEN CAST(revenue-spend AS DECIMAL(10,4))*100 / spend
                ELSE NULL
            END AS roi,  --(Return on Investment)
            CASE
                WHEN clicks>0
                THEN CAST(spend AS DECIMAL(10,4)) / clicks
                ELSE NULL
            END AS cost_per_click,
            CASE
                WHEN conversions>0
                THEN CAST(spend AS DECIMAL(10,4)) / conversions
                ELSE NULL
            END AS cost_per_conversion,
            CASE
                WHEN conversions>0
                THEN CAST(revenue AS DECIMAL(10,4)) / conversions
                ELSE NULL
            END AS revenue_per_conversion
        FROM bronze.marketing
        WHERE campaign_id IS NOT NULL;

        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT '';
        /*
        =====================================================
        TABLE 4: silver.orders
        =====================================================
        */
        SET @TableName = 'silver.orders';
        SET @StartTime = SYSDATETIME();
        PRINT '[4/7] Loading ' + @TableName + '...';
        
        INSERT INTO silver.orders (
            order_id,
            cst_id,
            order_date,
            promised_time,
            actual_time,
            order_total,
            payment_method,
            delivery_partner_id,
            store_id,
            -- Derived columns
            order_year,
            order_month,
            order_quarter,
            order_day_of_week,
            order_hour,
            delivery_time_minutes,
            delivery_delay_minutes,
            delivery_status
        )
        SELECT
            o.order_id,
            o.cst_id,
            o.order_date,
            o.promised_time,
            o.actual_time,
            o.order_total,
            ISNULL(o.payment_method, 'Cash') AS payment_method, --Handle NULL values
            o.delivery_partner_id,
            o.store_id,
            -- Derived columns
            YEAR(o.order_date) AS order_year,
            MONTH(o.order_date) AS order_month,
            DATEPART(QUARTER, o.order_date) AS order_quarter,
            DATENAME(WEEKDAY,o.order_date) AS order_day_of_week,
            DATEPART(HOUR, o.order_date) AS order_hour,
            DATEDIFF(MINUTE,o.order_date, o.actual_time) AS delivery_time_minutes,
            DATEDIFF(MINUTE,o.promised_time, o.actual_time) AS delivery_delay_minutes,
            CASE 
                WHEN DATEDIFF(MINUTE,o.promised_time, o.actual_time) <-5 THEN 'Early'
                WHEN DATEDIFF(MINUTE,o.promised_time, o.actual_time)
                BETWEEN -5 AND 0 THEN 'On Time'
                WHEN DATEDIFF(MINUTE,o.promised_time, o.actual_time)
                BETWEEN 1 AND 5 THEN 'Slightly Delayed'
                WHEN DATEDIFF(MINUTE,o.promised_time, o.actual_time) > 5 THEN 'Delayed'
                ELSE 'Unknown'
            END AS delivery_status
        FROM bronze.orders o
        INNER JOIN silver.cst c ON o.cst_id = c.cst_id
        WHERE o.order_id IS NOT NULL 
          AND o.order_date IS NOT NULL;
        
        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT '';
        /*
        =====================================================
        TABLE 5: silver.order_items
        =====================================================
        */
        SET @TableName = 'silver.order_items';
        SET @StartTime = SYSDATETIME();
        PRINT '[5/7] Loading ' + @TableName + '...';

        INSERT INTO silver.order_items (
            order_id,
            product_id,
            quantity,
            unit_price,
            line_total
        )
        SELECT
            oi.order_id,
            oi.product_id,
            oi.quantity,
            oi.unit_price,
            -- Derived columns
            oi.quantity * oi.unit_price AS line_total
        FROM bronze.order_items oi
        INNER JOIN silver.orders o ON oi.order_id = o.order_id
        INNER JOIN silver.products p ON oi.product_id = p.product_id
        WHERE oi.order_id IS NOT NULL
          AND oi.product_id IS NOT NULL
          AND oi.quantity > 0;
        
        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT '';

        /*
        =====================================================
        TABLE 6: silver.delivery
        =====================================================
        */
        SET @TableName = 'silver.delivery';
        SET @StartTime = SYSDATETIME();
        PRINT '[6/7] Loading ' + @TableName + '...';
        
        INSERT INTO silver.delivery (
            order_id,
            delivery_partner_id,
            distance_km
        )
        SELECT
            d.order_id,
            d.delivery_partner_id,
            d.distance_km
        FROM bronze.delivery d
        INNER JOIN silver.orders o ON d.order_id = o.order_id
        WHERE d.order_id IS NOT NULL
            AND d.Distance_km>0 ;--Filter Invalid Disatances
         
        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT '';
        /*
        =====================================================
        TABLE 7: silver.feedback
        =====================================================
        */
        SET @TableName = 'silver.feedback';
        SET @StartTime = SYSDATETIME();
        PRINT '[7/7] Loading ' + @TableName + '...';
        
        INSERT INTO silver.feedback (
            feedback_id,
            order_id,
            cst_id,
            rating,
            feedback_category,
            sentiment,
            feedback_date
        )
        SELECT
	        f.feedback_id,
            f.order_id,
            f.cst_id,
            f.rating,
            TRIM(LOWER(f.feedback_category)) AS feedback_category,
            TRIM(LOWER(f.sentiment)) AS sentiment,
            f.feedback_date
        FROM bronze.feedback f
        INNER JOIN silver.orders o ON f.order_id = o.order_id
        INNER JOIN silver.cst c ON f.cst_id = c.cst_id
        WHERE f.rating IS NOT NULL 
          AND f.feedback_date IS NOT NULL;
            
        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT '';
        /*
        =====================================================
        Final Summary
        =====================================================
        */
        SET @TotalEndTime = SYSDATETIME();
        SET @TotalDuration = DATEDIFF(MILLISECOND, @TotalStartTime, @TotalEndTime) / 1000.0;
        
        PRINT '========================================';
        PRINT 'SILVER LAYER - DATA LOAD COMPLETED';
        PRINT 'Total Duration: ' + CAST(@TotalDuration AS NVARCHAR(10)) + ' seconds';
        PRINT '========================================';
        PRINT '';
        PRINT 'All tables loaded successfully!';
        PRINT '';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
    PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
		PRINT 'Error Message  ' + ERROR_MESSAGE();
		PRINT 'Error Message  ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message  ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
END CATCH
END

EXEC silver.load_silver --TO EXECUTE THE STORED PROCEDURE