/*
===============================================================================
Stored Procedure: Load Bronze Layer
===============================================================================
Script Purpose:
    This stored procedure loads raw data into 'bronze' schema from external
    CSV files using BULK INSERT.
    It truncates the bronze tables before loading data.
===============================================================================

*/
USE bigbasket_DB;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
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
        -- Overall timing
        SET @TotalStartTime = SYSDATETIME();
        PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

        /*
        =====================================================
        TABLE 1: bronze.cst
        =====================================================
        */
        SET @TableName = 'bronze.cst';
        SET @StartTime = SYSDATETIME();
        PRINT '[1/7] Loading ' + @TableName + '...';

        TRUNCATE TABLE bronze.cst;  -- Clear existing data
        
        BULK INSERT bronze.cst
        FROM 'E:\Projects\raw-data\customers.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        
        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT ''
        /*
        =====================================================
        TABLE 2: bronze.orders
        =====================================================
        */
        SET @TableName = 'bronze.orders';
        SET @StartTime = SYSDATETIME();
        PRINT '[2/7] Loading ' + @TableName + '...';
        
        TRUNCATE TABLE bronze.orders;
        
        BULK INSERT bronze.orders
        FROM 'E:\Projects\raw-data\orders.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        
        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT ''
        /*
        =====================================================
        TABLE 3: bronze.order_items
        =====================================================
        */
        SET @TableName = 'bronze.order_items';
        SET @StartTime = SYSDATETIME();
        PRINT '[3/7] Loading ' + @TableName + '...';
        
        TRUNCATE TABLE bronze.order_items;
        
        BULK INSERT bronze.order_items
        FROM 'E:\Projects\raw-data\order_items.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        
        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT ''
        /*
        =====================================================
        TABLE 4: bronze.products
        =====================================================
        */
        SET @TableName = 'bronze.products';
        SET @StartTime = SYSDATETIME();
        PRINT '[4/7] Loading ' + @TableName + '...';
        
        TRUNCATE TABLE bronze.products;
        
        BULK INSERT bronze.products
        FROM 'E:\Projects\raw-data\products.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        
        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT ''
        /*
        =====================================================
        TABLE 5: bronze.delivery
        =====================================================
        */
        SET @TableName = 'bronze.delivery';
        SET @StartTime = SYSDATETIME();
        PRINT '[5/7] Loading ' + @TableName + '...';
        
        TRUNCATE TABLE bronze.delivery;
        
        BULK INSERT bronze.delivery
        FROM 'E:\Projects\raw-data\delivery_performance.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        
        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT ''
        /*
        =====================================================
        TABLE 6: bronze.feedback
        =====================================================
        */
        SET @TableName = 'bronze.feedback';
        SET @StartTime = SYSDATETIME();
        PRINT '[6/7] Loading ' + @TableName + '...';
        
        TRUNCATE TABLE bronze.feedback;
        
        BULK INSERT bronze.feedback
        FROM 'E:\Projects\raw-data\customer_feedback.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        
        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT ''

        /*
        =====================================================
        TABLE 7: bronze.marketing
        =====================================================
        */
        SET @TableName = 'bronze.marketing';
        SET @StartTime = SYSDATETIME();
        PRINT '[7/7] Loading ' + @TableName + '...';
        
        TRUNCATE TABLE bronze.marketing;
        
        BULK INSERT bronze.marketing
        FROM 'E:\Projects\raw-data\marketing_performance.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        
        SET @EndTime = SYSDATETIME();
        SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0;
        PRINT 'Load Duration: ' + CAST(@Duration AS NVARCHAR(10)) + 's';
        PRINT ''
        /*
        =====================================================
        Final Summary
        =====================================================
        */
        SET @TotalEndTime = SYSDATETIME();
        SET @TotalDuration = DATEDIFF(MILLISECOND, @TotalStartTime, @TotalEndTime) / 1000.0;
        
        PRINT '========================================';
        PRINT 'BRONZE LAYER - DATA LOAD COMPLETED';
        PRINT 'Total Duration: ' + CAST(@TotalDuration AS NVARCHAR(10)) + ' seconds';
        PRINT '========================================';
        PRINT '';
        PRINT 'All tables loaded successfully!';
        PRINT '';
        
    END TRY
    BEGIN CATCH
        PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message  ' + ERROR_MESSAGE();
		PRINT 'Error Message  ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message  ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
        
EXEC bronze.load_bronze --TO EXECUTE THE STORED PROCEDURE
