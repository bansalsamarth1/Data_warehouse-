# 📖 Data Dictionary
### Data Warehouse — Medallion Architecture

> This document defines every table and column across the Bronze, Silver, and Gold layers.
> Use this as the single source of truth for understanding what each field means, where it comes from, and how it was transformed.

---

## 🗺️ Quick Navigation

| Layer | Tables |
|-------|--------|
| 🥉 Bronze | [crm_cust_info](#-bronzecrm_cust_info) · [crm_prd_info](#-bronzecrm_prd_info) · [crm_sales_details](#-bronzecrm_sales_details) · [erp_loc_a101](#-bronzeerp_loc_a101) · [erp_cust_az12](#-bronzeerp_cust_az12) · [erp_px_cat_g1v2](#-bronzeerp_px_cat_g1v2) |
| 🥈 Silver | [crm_cust_info](#-silvercrm_cust_info) · [crm_prd_info](#-silvercrm_prd_info) · [crm_sales_details](#-silvercrm_sales_details) · [erp_loc_a101](#-silvererp_loc_a101) · [erp_cust_az12](#-silvererp_cust_az12) · [erp_px_cat_g1v2](#-silvererp_px_cat_g1v2) |
| 🥇 Gold | [dim_customers](#-golddim_customers) · [dim_products](#-golddim_products) · [fact_sales](#-goldfact_sales) |

---

## 🥉 BRONZE LAYER
> Raw data ingested as-is from source systems. **No transformations applied.**

---

### 🥉 `bronze.crm_cust_info`
**Source:** CRM System · **File:** `source_crm/cust_info.csv`
> Core customer master data from the CRM. Contains one row per customer record, but may have duplicates due to system re-exports.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| `cst_id` | INT | Numeric customer identifier assigned by the CRM. May have duplicates in raw data. | `12345` |
| `cst_key` | NVARCHAR(50) | Alphanumeric business key for the customer — used to join across CRM and ERP systems. | `AW-00001` |
| `cst_firstname` | NVARCHAR(50) | Customer's first name. May contain leading/trailing spaces in raw form. | `' John '` |
| `cst_lastname` | NVARCHAR(50) | Customer's last name. May contain leading/trailing spaces in raw form. | `' Doe '` |
| `cst_material_status` | NVARCHAR(50) | Marital status as a raw code. **Note:** Column is intentionally misspelled in source. | `'S'`, `'M'` |
| `cst_gndr` | NVARCHAR(50) | Gender as a raw code from CRM. | `'M'`, `'F'`, `'n/a'` |
| `cst_create_date` | DATE | Date the customer record was created in the CRM system. | `2021-03-15` |

---

### 🥉 `bronze.crm_prd_info`
**Source:** CRM System · **File:** `source_crm/prd_info.csv`
> Product catalog from the CRM including pricing and lifecycle dates.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| `prd_id` | INT | Numeric product identifier from the CRM. | `101` |
| `prd_key` | NVARCHAR(50) | Alphanumeric product business key. The first 5 characters encode the category. | `'WB-H108'` |
| `prd_nm` | NVARCHAR(50) | Full product name as stored in CRM. | `'Mountain Bike Helmet'` |
| `prd_cost` | INT | Product cost in whole currency units. May be NULL for some records. | `45` |
| `prd_line` | NVARCHAR(50) | Single-letter product line code from CRM. | `'M'`, `'R'`, `'S'`, `'T'` |
| `prd_start_dt` | DATETIME | Date this version of the product record became active. Used for SCD logic. | `2021-01-01` |
| `prd_end_dt` | DATETIME | Date this version of the product record was superseded. NULL = currently active. | `NULL`, `2022-12-31` |

---

### 🥉 `bronze.crm_sales_details`
**Source:** CRM System · **File:** `source_crm/sales_details.csv`
> Individual sales transaction records. Dates are stored as integers in YYYYMMDD format.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| `sls_ord_num` | NVARCHAR(50) | Unique sales order number. Business identifier for the transaction. | `'SO-001234'` |
| `sls_prd_key` | NVARCHAR(50) | Product key with a `FC-01-` prefix prepended by the CRM. Must be stripped to join to product tables. | `'FC-01-WB-H108'` |
| `sls_cust_id` | INT | Customer ID matching `crm_cust_info.cst_id`. | `12345` |
| `sls_order_dt` | INT | Order date stored as an integer in YYYYMMDD format. | `20210315` |
| `sls_ship_dt` | INT | Shipping date stored as an integer in YYYYMMDD format. | `20210322` |
| `sls_due_dt` | INT | Payment due date stored as an integer in YYYYMMDD format. | `20210415` |
| `sls_sales` | INT | Total sales amount for the order line. May be inconsistent with `quantity × price` in raw data. | `450` |
| `sls_quantity` | INT | Number of units sold. | `10` |
| `sls_price` | INT | Unit price at time of sale. May be negative or NULL in raw data. | `45` |

---

### 🥉 `bronze.erp_loc_a101`
**Source:** ERP System · **File:** `source_erp/LOC_A101.csv`
> Customer location/country data from the ERP system.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| `cid` | NVARCHAR(50) | Customer identifier from ERP. May contain a `-` separator that needs to be removed to join with CRM keys. | `'AW-00001'` |
| `cntry` | NVARCHAR(50) | Country code or name as stored in ERP. Inconsistent — may be ISO code or full name. | `'US'`, `'USA'`, `'DE'`, `'Australia'` |

---

### 🥉 `bronze.erp_cust_az12`
**Source:** ERP System · **File:** `source_erp/CUST_AZ12.csv`
> Supplementary customer demographic data from ERP, primarily birthdate and gender.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| `cid` | NVARCHAR(50) | Customer identifier from ERP. Some records have a `NAS` prefix that must be stripped to join with CRM. | `'NASAW00001'`, `'AW00001'` |
| `bdate` | DATE | Customer birthdate. Raw data may contain future dates (data entry errors). | `1985-06-20` |
| `gen` | NVARCHAR(50) | Gender from ERP. Inconsistent coding — may be single letter or full word. | `'M'`, `'Male'`, `'F'`, `'Female'` |

---

### 🥉 `bronze.erp_px_cat_g1v2`
**Source:** ERP System · **File:** `source_erp/PX_CAT_G1V2.csv`
> Product category and subcategory reference data from the ERP system.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| `id` | NVARCHAR(50) | Category identifier. Matches the first 5 characters of `crm_prd_info.prd_key` after formatting. | `'WB_H10'` |
| `cat` | NVARCHAR(50) | Top-level product category name. | `'Bikes'`, `'Accessories'` |
| `subcat` | NVARCHAR(50) | Product subcategory name. | `'Mountain Bikes'`, `'Helmets'` |
| `maintenance` | NVARCHAR(50) | Indicates whether the product requires ongoing maintenance. | `'Yes'`, `'No'` |

---
---

## 🥈 SILVER LAYER
> Cleansed, standardized, and deduplicated data. Ready for analysis and Gold layer joins.
> Every table includes a `dwh_create_date` audit column.

---

### 🥈 `silver.crm_cust_info`
**Loaded by:** `silver.load_silver` procedure
> Deduplicated and standardized customer records. One row per customer guaranteed.

| Column | Data Type | Description | Transformation from Bronze |
|--------|-----------|-------------|---------------------------|
| `cst_id` | INT | Unique customer identifier. **Primary key in this layer.** | Deduplicated using `ROW_NUMBER()` — latest record per `cst_id` is kept |
| `cst_key` | NVARCHAR(50) | Business key used to join with ERP tables. | Carried over as-is |
| `cst_firstname` | NVARCHAR(50) | Customer's first name, trimmed. | `TRIM()` applied to remove whitespace |
| `cst_lastname` | NVARCHAR(50) | Customer's last name, trimmed. | `TRIM()` applied to remove whitespace |
| `cst_marital_status` | NVARCHAR(50) | Marital status in human-readable form. | `'S'` → `'Single'`, `'M'` → `'Married'`, else `'n/a'` |
| `cst_gndr` | NVARCHAR(50) | Gender in human-readable form. | `'M'` → `'Male'`, `'F'` → `'Female'`, else `'n/a'` |
| `cst_create_date` | DATE | Original CRM record creation date. | Carried over as-is |
| `dwh_create_date` | DATETIME2 | Timestamp of when this row was loaded into the Silver layer. | Auto-populated via `DEFAULT GETDATE()` |

---

### 🥈 `silver.crm_prd_info`
**Loaded by:** `silver.load_silver` procedure
> Product catalog with decoded product lines and derived SCD end dates.

| Column | Data Type | Description | Transformation from Bronze |
|--------|-----------|-------------|---------------------------|
| `prd_id` | INT | Product identifier. | Carried over as-is |
| `prd_key` | NVARCHAR(50) | Product business key. | Carried over as-is |
| `prd_nm` | NVARCHAR(50) | Product name. | Carried over as-is |
| `prd_cost` | INT | Product cost. NULL values replaced with 0. | `ISNULL(prd_cost, 0)` |
| `prd_line` | NVARCHAR(50) | Product line in full descriptive text. | `'M'`→`'Mountain'`, `'R'`→`'Road'`, `'S'`→`'Other Sales'`, `'T'`→`'Touring'`, else `'n/a'` |
| `prd_start_dt` | DATETIME | Date this product version became active. | Carried over as-is |
| `prd_end_dt` | DATETIME | Date this product version was replaced. Derived — not stored in source. | Calculated using `LEAD(prd_start_dt) - 1` over product key partition |
| `dwh_create_date` | DATETIME2 | Timestamp of Silver layer load. | Auto-populated via `DEFAULT GETDATE()` |

---

### 🥈 `silver.crm_sales_details`
**Loaded by:** `silver.load_silver` procedure
> Sales transactions with corrected financial values. Dates remain as integers here.

| Column | Data Type | Description | Transformation from Bronze |
|--------|-----------|-------------|---------------------------|
| `sls_ord_num` | NVARCHAR(50) | Unique order number. | Carried over as-is |
| `sls_prd_key` | NVARCHAR(50) | Product key with `FC-01-` prefix still intact. Stripped only in Gold layer join. | Carried over as-is |
| `sls_cust_id` | INT | Customer ID linking to `crm_cust_info`. | Carried over as-is |
| `sls_order_dt` | INT | Order date as integer (YYYYMMDD). Cast to DATE only in Gold layer. | Carried over as-is |
| `sls_ship_dt` | INT | Ship date as integer (YYYYMMDD). | Carried over as-is |
| `sls_due_dt` | INT | Due date as integer (YYYYMMDD). | Carried over as-is |
| `sls_sales` | INT | Corrected sales amount. | If NULL, zero, or inconsistent: recalculated as `quantity × ABS(price)` |
| `sls_quantity` | INT | Units sold. | Carried over as-is |
| `sls_price` | INT | Unit price. | If NULL or negative: recalculated as `sales / quantity` |
| `dwh_create_date` | DATETIME2 | Timestamp of Silver layer load. | Auto-populated via `DEFAULT GETDATE()` |

---

### 🥈 `silver.erp_loc_a101`
**Loaded by:** `silver.load_silver` procedure
> Standardized customer country data with consistent country names.

| Column | Data Type | Description | Transformation from Bronze |
|--------|-----------|-------------|---------------------------|
| `cid` | NVARCHAR(50) | Customer ID with `-` separator removed to align with CRM key format. | `REPLACE(cid, '-', '')` |
| `cntry` | NVARCHAR(50) | Standardized full country name. | `'DE'`→`'Germany'`, `'US'`/`'USA'`→`'United States'`, blank/NULL→`'n/a'` |
| `dwh_create_date` | DATETIME2 | Timestamp of Silver layer load. | Auto-populated via `DEFAULT GETDATE()` |

---

### 🥈 `silver.erp_cust_az12`
**Loaded by:** `silver.load_silver` procedure
> Cleaned customer demographics with valid birthdates and standardized gender.

| Column | Data Type | Description | Transformation from Bronze |
|--------|-----------|-------------|---------------------------|
| `cid` | NVARCHAR(50) | Customer ID with `NAS` prefix stripped to align with CRM key format. | `SUBSTRING(cid, 4, LEN)` applied when value starts with `'NAS'` |
| `bdate` | DATE | Customer birthdate. Future dates nullified. | `IF bdate > GETDATE() THEN NULL` |
| `gen` | NVARCHAR(50) | Standardized gender. | `'F'`/`'Female'`→`'Female'`, `'M'`/`'Male'`→`'Male'`, else `'n/a'` |
| `dwh_create_date` | DATETIME2 | Timestamp of Silver layer load. | Auto-populated via `DEFAULT GETDATE()` |

---

### 🥈 `silver.erp_px_cat_g1v2`
**Loaded by:** `silver.load_silver` procedure
> Product category reference data. Passed through with no transformations beyond audit column.

| Column | Data Type | Description | Transformation from Bronze |
|--------|-----------|-------------|---------------------------|
| `id` | NVARCHAR(50) | Category ID used to join with product tables. | Carried over as-is |
| `cat` | NVARCHAR(50) | Top-level product category. | Carried over as-is |
| `subcat` | NVARCHAR(50) | Product subcategory. | Carried over as-is |
| `maintenance` | NVARCHAR(50) | Whether product requires maintenance. | Carried over as-is |
| `dwh_create_date` | DATETIME2 | Timestamp of Silver layer load. | Auto-populated via `DEFAULT GETDATE()` |

---
---

## 🥇 GOLD LAYER
> Business-ready views forming a Star Schema. These are the **only objects** that reporting tools (Power BI, Tableau) should connect to.

---

### 🥇 `gold.dim_customers`
**Type:** Dimension View · **Source:** `silver.crm_cust_info` + `silver.erp_cust_az12` + `silver.erp_loc_a101`
> Unified 360° customer profile — merges CRM identity data with ERP demographics and location.

| Column | Data Type | Description | Source / Logic |
|--------|-----------|-------------|----------------|
| `customer_key` | INT | **Surrogate primary key.** System-generated integer, independent of source IDs. | `ROW_NUMBER() OVER (ORDER BY cst_id)` |
| `customer_id` | INT | Original numeric CRM customer ID. Retained for traceability back to source. | `silver.crm_cust_info.cst_id` |
| `customer_number` | NVARCHAR(50) | Alphanumeric business key used across CRM and ERP systems. | `silver.crm_cust_info.cst_key` |
| `first_name` | NVARCHAR(50) | Customer's first name. | `silver.crm_cust_info.cst_firstname` |
| `last_name` | NVARCHAR(50) | Customer's last name. | `silver.crm_cust_info.cst_lastname` |
| `country` | NVARCHAR(50) | Customer's country of residence (standardized full name). | `silver.erp_loc_a101.cntry` |
| `marital_status` | NVARCHAR(50) | Customer's marital status in readable form. | `silver.crm_cust_info.cst_marital_status` |
| `gender` | NVARCHAR(50) | Resolved gender — **CRM takes priority** over ERP. | `IF crm.gender != 'n/a' → CRM ELSE ERP value` |
| `birthdate` | DATE | Customer's date of birth (future dates removed in Silver). | `silver.erp_cust_az12.bdate` |
| `create_date` | DATE | Date the customer was first registered in the CRM. | `silver.crm_cust_info.cst_create_date` |

---

### 🥇 `gold.dim_products`
**Type:** Dimension View · **Source:** `silver.crm_prd_info` + `silver.erp_px_cat_g1v2`
> Current active product catalog with full category enrichment. Historical/expired products are excluded.

| Column | Data Type | Description | Source / Logic |
|--------|-----------|-------------|----------------|
| `product_key` | INT | **Surrogate primary key.** System-generated integer. | `ROW_NUMBER() OVER (ORDER BY prd_start_dt, prd_key)` |
| `product_id` | INT | Original numeric CRM product ID. Retained for traceability. | `silver.crm_prd_info.prd_id` |
| `product_number` | NVARCHAR(50) | Short alphanumeric product key without prefix. Used to join with `fact_sales`. | `silver.crm_prd_info.prd_key` |
| `product_name` | NVARCHAR(50) | Full descriptive product name. | `silver.crm_prd_info.prd_nm` |
| `category_id` | NVARCHAR(50) | Derived category ID extracted from product key characters 1–5. | `REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_')` |
| `category` | NVARCHAR(50) | Top-level product category (e.g., Bikes, Accessories). | `silver.erp_px_cat_g1v2.cat` |
| `subcategory` | NVARCHAR(50) | Product subcategory (e.g., Mountain Bikes, Helmets). | `silver.erp_px_cat_g1v2.subcat` |
| `maintenance` | NVARCHAR(50) | Whether the product requires maintenance servicing. | `silver.erp_px_cat_g1v2.maintenance` |
| `cost` | INT | Product cost in whole currency units. | `silver.crm_prd_info.prd_cost` |
| `product_line` | NVARCHAR(50) | Product line category (Mountain, Road, Touring, Other Sales). | `silver.crm_prd_info.prd_line` |
| `start_date` | DATETIME | Date this product version became active. | `silver.crm_prd_info.prd_start_dt` |

> ⚠️ **Important:** This view filters `WHERE prd_end_dt IS NULL` — only **currently active** products are visible. This implements **SCD Type 1** behaviour at the view level.

---

### 🥇 `gold.fact_sales`
**Type:** Fact View · **Source:** `silver.crm_sales_details` + `gold.dim_products` + `gold.dim_customers`
> Central fact table containing all sales transactions, linked to dimension tables via surrogate keys.

| Column | Data Type | Description | Source / Logic |
|--------|-----------|-------------|----------------|
| `order_number` | NVARCHAR(50) | Unique business identifier for each sales order. | `silver.crm_sales_details.sls_ord_num` |
| `product_key` | INT | **Foreign key** to `gold.dim_products.product_key`. | Joined by stripping `FC-01-` prefix from `sls_prd_key` to match `product_number` |
| `customer_key` | INT | **Foreign key** to `gold.dim_customers.customer_key`. | Joined via `sls_cust_id = customer_id` |
| `order_date` | DATE | Date the order was placed. Converted from INT to DATE. | `TRY_CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)` |
| `shipping_date` | DATE | Date the order was shipped. Converted from INT to DATE. | `TRY_CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)` |
| `due_date` | DATE | Payment due date. Converted from INT to DATE. | `TRY_CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)` |
| `sales_amount` | INT | Total revenue for this order line (corrected in Silver). | `silver.crm_sales_details.sls_sales` |
| `quantity` | INT | Number of units sold in this order line. | `silver.crm_sales_details.sls_quantity` |
| `price` | INT | Unit price at time of sale (corrected in Silver). | `silver.crm_sales_details.sls_price` |

---

## 📝 Notes & Design Decisions

| Decision | Explanation |
|----------|-------------|
| **Surrogate Keys in Gold** | Natural keys from source systems (`cst_id`, `prd_id`) are replaced with system-generated surrogate keys (`customer_key`, `product_key`) in the Gold layer. This decouples the warehouse from source system changes. |
| **CRM Gender Priority** | When both CRM and ERP provide gender, CRM is treated as the system of record. ERP is only used as a fallback when CRM value is `'n/a'`. |
| **SCD Type 1 in dim_products** | Only the current version of each product is exposed in the Gold view. Historical product versions exist in Silver but are filtered out with `WHERE prd_end_dt IS NULL`. |
| **INT Date Storage in Silver** | Sales dates are intentionally kept as integers in the Silver layer, matching the source exactly. The conversion to `DATE` happens only in the Gold fact view using `TRY_CAST` to safely handle any malformed values. |
| **Bronze Column Typo Preserved** | The Bronze table `crm_cust_info` has `cst_material_status` (misspelled). This is intentional — Bronze preserves raw source data exactly. The corrected column name `cst_marital_status` appears from Silver onward. |
| **`NAS` Prefix in ERP** | Some customer IDs in `erp_cust_az12` have a `NAS` prefix not present in the CRM. This is stripped in the Silver layer to enable correct joining. |
