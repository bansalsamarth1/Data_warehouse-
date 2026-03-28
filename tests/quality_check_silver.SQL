/*******************************************************************************
Script: Data Quality Checks - Silver Layer
Author: Samarth Bansal
Date: 2026-03-28
Description: 
    This script performs post-load validation for the 'silver' schema. 
    It identifies data anomalies, integrity violations, and standardization 
    issues.

Expectation: 
    For most checks, the goal is 'Zero Results'. If rows are returned, 
    data cleaning logic in the 'load_silver' procedure may need adjustment.
*******************************************************************************/

USE DataWarehouse;
GO

PRINT '===============================================================';
PRINT 'Starting Data Quality Checks for Silver Layer';
PRINT '===============================================================';

-------------------------------------------------------------------------------
-- 1. Checking 'silver.crm_cust_info'
-------------------------------------------------------------------------------
PRINT '---------------------------------------------------------------';
PRINT '>> Checking silver.crm_cust_info';
PRINT '---------------------------------------------------------------';

-- Check for NULLs or Duplicates in Primary Key
PRINT 'Check 1: NULLs or Duplicates in cst_id (Expectation: 0 Results)';
SELECT cst_id, COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces in Keys
PRINT 'Check 2: Unwanted spaces in cst_key (Expectation: 0 Results)';
SELECT cst_key FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Verify Data Standardization (Marital Status)
PRINT 'Check 3: Distinct values for cst_marital_status (Expectation: Cleaned labels)';
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;

-------------------------------------------------------------------------------
-- 2. Checking 'silver.crm_prd_info'
-------------------------------------------------------------------------------
PRINT '---------------------------------------------------------------';
PRINT '>> Checking silver.crm_prd_info';
PRINT '---------------------------------------------------------------';

-- Check for NULLs or Duplicates in Primary Key
PRINT 'Check 1: NULLs or Duplicates in prd_id (Expectation: 0 Results)';
SELECT prd_id, COUNT(*) AS record_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for NULLs or Negative Values in Cost
PRINT 'Check 2: Invalid Cost values (Expectation: 0 Results)';
SELECT prd_cost FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Verify Date Logic
PRINT 'Check 3: Invalid Date Orders (Expectation: 0 Results)';
SELECT * FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-------------------------------------------------------------------------------
-- 3. Checking 'silver.crm_sales_details'
-------------------------------------------------------------------------------
PRINT '---------------------------------------------------------------';
PRINT '>> Checking silver.crm_sales_details';
PRINT '---------------------------------------------------------------';

-- Check Date Logical Consistency
PRINT 'Check 1: Order date after Shipping/Due dates (Expectation: 0 Results)';
SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Check Math Consistency (Sales = Quantity * Price)
PRINT 'Check 2: Mathematical consistency (Expectation: 0 Results)';
-- Note: Check if $Sales \neq Quantity \times Price$
SELECT sls_sales, sls_quantity, sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;

-------------------------------------------------------------------------------
-- 4. Checking ERP Source Tables (AZ12, A101, G1V2)
-------------------------------------------------------------------------------
PRINT '---------------------------------------------------------------';
PRINT '>> Checking ERP Source Schema Tables';
PRINT '---------------------------------------------------------------';

-- Verify Birthdate Ranges in erp_cust_az12
PRINT 'Check 1: Out-of-range Birthdates in az12 (Expectation: 1924 to Present)';
SELECT DISTINCT bdate FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Verify Country Standardization in erp_loc_a101
PRINT 'Check 2: Country name consistency in a101 (Expectation: Standardized names)';
SELECT DISTINCT cntry FROM silver.erp_loc_a101 ORDER BY cntry;

-- Check for Spaces in Category Mapping
PRINT 'Check 3: Trim check for erp_px_cat_g1v2 (Expectation: 0 Results)';
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

PRINT '===============================================================';
PRINT 'Quality Checks Complete';
PRINT '===============================================================';
