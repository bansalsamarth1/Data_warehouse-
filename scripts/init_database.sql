/*******************************************************************************
Project: DataWarehouse - Medallion Architecture Setup
Author: Samarth Bansal
Date: 2026-03-27
Description: 
    This script initializes the DataWarehouse environment. 
    It ensures a clean slate by dropping the existing database and 
    creating the logical separation layers (Bronze, Silver, Gold).

Instructions:
    1. Open SQL Server Management Studio (SSMS) or Azure Data Studio.
    2. Connect to your instance (e.g., .\SQLEXPRESS02).
    3. Execute this script as a user with 'sysadmin' or 'dbcreator' permissions.
*******************************************************************************/

USE master;
GO

-- 1. Check if the database exists and drop it to ensure a clean start
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'DataWarehouse')
BEGIN
    PRINT 'Existing DataWarehouse found. Dropping database...';
    -- Altering to single_user forces existing connections (like SSMS tabs) to close
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END
GO

-- 2. Create the new DataWarehouse database
PRINT 'Creating DataWarehouse database...';
CREATE DATABASE DataWarehouse;
GO

-- 3. Switch context to the new database
USE DataWarehouse;
GO

-- 4. Create the Medallion Architecture Schemas
-- Bronze: Raw data ingestion layer
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze');
    PRINT 'Schema [bronze] created.';
END
GO

-- Silver: Cleaned and transformed data layer
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
    PRINT 'Schema [silver] created.';
END
GO

-- Gold: Business-ready / Analytical layer
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold');
    PRINT 'Schema [gold] created.';
END
GO

PRINT 'Database Initialization Complete.';
