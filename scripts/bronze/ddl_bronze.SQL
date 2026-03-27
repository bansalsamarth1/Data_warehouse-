/*******************************************************************************
Project: DataWarehouse - Bronze Layer Schema Definition
Author: Samarth Bansal
Date: 2026-03-27
Description: 
    This script defines the physical table structures for the Bronze Layer.
    These tables are designed to hold RAW data from two source systems:
    1. CRM (Customer Relationship Management)
    2. ERP (Enterprise Resource Planning)

Warning:
    Running this script will NOT delete existing data, but if you modify 
    column types here, you may need to manually drop the tables first.
    Ensure the 'DataWarehouse' database exists before running this.
*******************************************************************************/

USE DataWarehouse;
GO

-- =============================================================================
-- CRM Tables
-- =============================================================================

-- Table: bronze.crm_cust_info
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.crm_cust_info (
        cst_id             INT,
        cst_key            NVARCHAR(50),
        cst_firstname      NVARCHAR(50),
        cst_lastname       |NVARCHAR(50),
        cst_material_status NVARCHAR(50),
        cst_gndr           NVARCHAR(50),
        cst_create_date    DATE
    );
    PRINT '>> Table bronze.crm_cust_info created.';
END
ELSE PRINT '>> Table bronze.crm_cust_info already exists. Skipping...';
GO

-- Table: bronze.crm_prd_info
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.crm_prd_info (
        prd_id       INT,
        prd_key      NVARCHAR(50),
        prd_nm       NVARCHAR(50),
        prd_cost     INT,
        prd_line     NVARCHAR(50),
        prd_start_dt DATETIME,
        prd_end_dt   DATETIME
    );
    PRINT '>> Table bronze.crm_prd_info created.';
END
ELSE PRINT '>> Table bronze.crm_prd_info already exists. Skipping...';
GO

-- Table: bronze.crm_sales_details
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.crm_sales_details (
        sls_ord_num  NVARCHAR(50),
        sls_prd_key  NVARCHAR(50),
        sls_cust_id  INT,
        sls_order_dt INT,
        sls_ship_dt  INT,
        sls_due_dt   INT,
        sls_sales    INT,
        sls_quantity INT,
        sls_price    INT
    );
    PRINT '>> Table bronze.crm_sales_details created.';
END
ELSE PRINT '>> Table bronze.crm_sales_details already exists. Skipping...';
GO

-- =============================================================================
-- ERP Tables
-- =============================================================================

-- Table: bronze.erp_loc_a101
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.erp_loc_a101 (
        cid    NVARCHAR(50),
        cntry  NVARCHAR(50)
    );
    PRINT '>> Table bronze.erp_loc_a101 created.';
END
ELSE PRINT '>> Table bronze.erp_loc_a101 already exists. Skipping...';
GO

-- Table: bronze.erp_cust_az12
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.erp_cust_az12 (
        cid    NVARCHAR(50),
        bdate  DATE,
        gen    NVARCHAR(50)
    );
    PRINT '>> Table bronze.erp_cust_az12 created.';
END
ELSE PRINT '>> Table bronze.erp_cust_az12 already exists. Skipping...';
GO

-- Table: bronze.erp_px_cat_g1v2
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.erp_px_cat_g1v2 (
        id           NVARCHAR(50),
        cat          NVARCHAR(50),
        subcat       NVARCHAR(50),
        maintenance  NVARCHAR(50)
    );
    PRINT '>> Table bronze.erp_px_cat_g1v2 created.';
END
ELSE PRINT '>> Table bronze.erp_px_cat_g1v2 already exists. Skipping...';
GO

PRINT 'Bronze Layer Schema Initialization Complete.';
