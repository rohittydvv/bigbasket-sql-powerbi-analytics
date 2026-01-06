/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'bronze' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.

Usage Notes:
    - Run these checks after data loading Bronze Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- Check duplicate or NULL customer IDs in bronze.cst
SELECT 
    cst_id,
    COUNT(*) 
FROM bronze.cst
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check if customer names have leading or trailing spaces in bronze.cst
SELECT COUNT(*)
FROM bronze.cst
WHERE (cst_name) != TRIM(cst_name);

-- Check if customer emails are not in lowercase in bronze.cst
SELECT COUNT(*)
FROM bronze.cst
WHERE (cst_email) != LOWER(cst_email);

-- Count customers with NULL emails in bronze.cst
SELECT COUNT(*)
FROM bronze.cst
WHERE (cst_email) IS NULL;

-- Count customers with NULL phone numbers in bronze.cst
SELECT COUNT(*)
FROM bronze.cst
WHERE (cst_phone) IS NULL;

-- Find customer pincodes not exactly 6 characters long in bronze.cst
SELECT cst_pincode
FROM bronze.cst
WHERE LEN(cst_pincode) != 6;

-- Count customers with NULL registration dates in bronze.cst
SELECT COUNT(*)
FROM bronze.cst
WHERE cst_reg_date IS NULL;

-- Check order IDs with NULL in bronze.orders
SELECT order_id,
       COUNT(*)
FROM bronze.orders
GROUP BY order_id
HAVING order_id IS NULL;

-- Find orders where order_date is after promised_time (illogical)
SELECT order_id
FROM bronze.orders
WHERE DATEDIFF(DAY, order_date, promised_time) > 0;

-- Find orders with zero or negative order_total in bronze.orders
SELECT order_id
FROM bronze.orders
WHERE order_total <= 0;

-- List all distinct payment methods used in bronze.orders
SELECT payment_method
FROM bronze.orders
GROUP BY payment_method;

-- Find order items with critical NULLs in quantities/prices
SELECT COUNT(*)
FROM bronze.order_items
WHERE order_id IS NULL OR product_id IS NULL OR quantity IS NULL OR unit_price IS NULL;

-- Check for leading/trailing spaces in product name, brand, or category in bronze.products
SELECT COUNT(*)
FROM bronze.products
WHERE product_name != TRIM(product_name)
   OR brand != TRIM(brand)
   OR category != TRIM(category);

-- Find products with illogical pricing: price greater than MRP, non-positive MRP or price
SELECT product_id, price, mrp
FROM bronze.products
WHERE price > mrp OR mrp <= 0 OR price <= 0;

-- Count feedback entries with NULL rating and feedback_date
SELECT COUNT(*)
FROM bronze.feedback
WHERE rating IS NULL AND feedback_date IS NULL;

-- Check for leading/trailing spaces in feedback_category in bronze.feedback
SELECT COUNT(*)
FROM bronze.feedback
WHERE feedback_category != TRIM(feedback_category);

-- Find feedback records missing critical keys in bronze.feedback
SELECT COUNT(*)
FROM bronze.feedback
WHERE feedback_id IS NULL OR order_id IS NULL OR cst_id IS NULL;

-- Find marketing records missing mandatory identifiers in bronze.marketing
SELECT *
FROM bronze.marketing
WHERE campaign_id IS NULL OR campaign_date IS NULL;

-- Check for leading/trailing spaces in marketing campaign names
SELECT COUNT(*)
FROM bronze.marketing
WHERE campaign_name != TRIM(campaign_name);

-- Count marketing records missing key performance metrics or attributes
SELECT COUNT(*)
FROM bronze.marketing
WHERE target_audience IS NULL
   OR revenue IS NULL
   OR impressions IS NULL
   OR clicks IS NULL
   OR conversions IS NULL
   OR spend IS NULL;
