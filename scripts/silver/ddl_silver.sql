/*******************************************************************************
Project: DataWarehouse - Silver Layer Schema Definition
Author: Samarth Bansal
Date: 2026-03-28
Description: 
    Physical table structures for the Silver Layer with Audit Metadata.
    Standardized 'dwh_create_date' added to track ingestion timing.

Warning:
    Ensure the 'silver' schema exists before running.
*******************************************************************************/

USE DataWarehouse;
GO

-- =============================================================================
-- CRM Tables (Cleansed)
-- =============================================================================

-- Table: silver.crm_cust_info
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NULL
BEGIN
    CREATE TABLE silver.crm_cust_info (
        cst_id              INT,
        cst_key             NVARCHAR(50),
        cst_firstname       NVARCHAR(50),
        cst_lastname        NVARCHAR(50),
        cst_marital_status  NVARCHAR(50),
        cst_gndr            NVARCHAR(50),
        cst_create_date     DATE,
        dwh_create_date     DATETIME2 DEFAULT GETDATE()
    );
    PRINT '>> Table silver.crm_cust_info created.';
END
GO

-- Table: silver.crm_prd_info
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NULL
BEGIN
    CREATE TABLE silver.crm_prd_info (
        prd_id              INT,
        prd_key             NVARCHAR(50),
        prd_nm              NVARCHAR(50),
        prd_cost            INT,
        prd_line            NVARCHAR(50),
        prd_start_dt        DATETIME,
        prd_end_dt          DATETIME,
        dwh_create_date     DATETIME2 DEFAULT GETDATE()
    );
    PRINT '>> Table silver.crm_prd_info created.';
END
GO

-- Table: silver.crm_sales_details
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NULL
BEGIN
    CREATE TABLE silver.crm_sales_details (
        sls_ord_num         NVARCHAR(50),
        sls_prd_key         NVARCHAR(50),
        sls_cust_id         INT,
        sls_order_dt        INT,
        sls_ship_dt         INT,
        sls_due_dt          INT,
        sls_sales           INT,
        sls_quantity        INT,
        sls_price           INT,
        dwh_create_date     DATETIME2 DEFAULT GETDATE()
    );
    PRINT '>> Table silver.crm_sales_details created.';
END
GO

-- =============================================================================
-- ERP Tables (Cleansed)
-- =============================================================================

-- Table: silver.erp_loc_a101
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NULL
BEGIN
    CREATE TABLE silver.erp_loc_a101 (
        cid                 NVARCHAR(50),
        cntry               NVARCHAR(50),
        dwh_create_date     DATETIME2 DEFAULT GETDATE()
    );
    PRINT '>> Table silver.erp_loc_a101 created.';
END
GO

-- Table: silver.erp_cust_az12
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NULL
BEGIN
    CREATE TABLE silver.erp_cust_az12 (
        cid                 NVARCHAR(50),
        bdate               DATE,
        gen                 NVARCHAR(50),
        dwh_create_date     DATETIME2 DEFAULT GETDATE()
    );
    PRINT '>> Table silver.erp_cust_az12 created.';
END
GO

-- Table: silver.erp_px_cat_g1v2
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NULL
BEGIN
    CREATE TABLE silver.erp_px_cat_g1v2 (
        id                  NVARCHAR(50),
        cat                 NVARCHAR(50),
        subcat              NVARCHAR(50),
        maintenance         NVARCHAR(50),
        dwh_create_date     DATETIME2 DEFAULT GETDATE()
    );
    PRINT '>> Table silver.erp_px_cat_g1v2 created.';
END
GO

PRINT 'Silver Layer Schema Initialization with Audit Columns Complete.';
