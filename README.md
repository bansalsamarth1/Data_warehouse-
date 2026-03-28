# 🏗️ Data Warehouse — Medallion Architecture
### *From Raw Chaos to Business Intelligence, One Layer at a Time*

![Architecture Diagram](docs/architecture_diagram.png)

---

## 📌 What Is This Project?

This project is a **fully functional Data Warehouse** built from scratch using **SQL Server**, implementing the industry-standard **Medallion Architecture** (Bronze → Silver → Gold).

It consolidates data from two separate source systems — a **CRM** and an **ERP** — cleanses and transforms it through structured layers, and delivers a clean **Star Schema** ready for reporting tools like **Power BI** or **Tableau**.

> Think of it as a pipeline that takes messy, raw business data and turns it into reliable, analytics-ready insights.

---

## ⚙️ Tech Stack

| Tool | Purpose |
|------|---------|
| **SQL Server** | Core database engine |
| **SSMS / Azure Data Studio** | Query execution & management |
| **T-SQL** | DDL, stored procedures, views |
| **Power BI / Tableau** | Downstream reporting (Gold layer output) |

---

## 🗂️ Project Structure

```
Data_warehouse/
│
├── scripts/
│   ├── init_database.sql          # Step 1: Create DB & all schemas
│   ├── bronze/
│   │   ├── ddl_bronze.SQL         # Step 2: Create raw Bronze tables
│   │   └── proc_load_bronze.SQL   # Step 3: Load raw data into Bronze
│   ├── silver/
│   │   ├── ddl_silver.sql         # Step 4: Create cleaned Silver tables
│   │   └── proc_load_silver.sql   # Step 5: Transform & load into Silver
│   └── gold/
│       └── gold_layer_views.sql   # Step 6: Create Star Schema views
│
├── tests/
│   └── quality_check_silver.SQL   # Data quality validation scripts
│
├── datasets/                      # Source CSV files for ingestion
├── docs/                          # Architecture & ERD diagrams
├── LICENSE
└── README.md
```

---

## 🥉🥈🥇 The Medallion Architecture

This warehouse is built on three progressive data layers, each serving a distinct purpose:

### 🥉 Bronze Layer — *Raw Ingestion*
> "Store everything, change nothing."

The Bronze layer is the **landing zone** for all raw data. Data is ingested exactly as-is from the source systems — no transformations, no filters, no fixes. This preserves the original source truth and acts as an audit trail.

**Source Tables Ingested:**
- `bronze.crm_cust_info` — Customer records from CRM
- `bronze.crm_prd_info` — Product catalog from CRM
- `bronze.crm_sales_details` — Sales transactions from CRM
- `bronze.erp_loc_a101` — Customer location data from ERP
- `bronze.erp_cust_az12` — Customer demographics from ERP
- `bronze.erp_px_cat_g1v2` — Product category mapping from ERP

---

### 🥈 Silver Layer — *Cleansed & Standardized*
> "Trust the data before you use it."

The Silver layer applies **business logic and data quality rules** to produce clean, reliable data. This is where the heavy lifting happens.

**Transformations Applied:**
- ✅ Duplicate removal & deduplication logic
- ✅ NULL handling and default value assignment
- ✅ Data type casting (e.g., INT dates → proper `DATE` format)
- ✅ String trimming and whitespace cleanup
- ✅ Gender & marital status standardization
- ✅ Audit column `dwh_create_date` added to every table

---

### 🥇 Gold Layer — *Star Schema (Business Ready)*
> "Analytics-ready. Report-friendly. Always accurate."

The Gold layer exposes **business-facing views** in a classic **Star Schema** — the industry standard for analytical reporting. All views are optimized for direct connection to Power BI or Tableau.

![Star Schema ERD](docs/star_schema_erd.png)

**Views Created:**

| Object | Type | Description |
|--------|------|-------------|
| `gold.dim_customers` | Dimension | Unified customer profile (CRM + ERP merged) |
| `gold.dim_products` | Dimension | Current active product catalog (SCD Type 1) |
| `gold.fact_sales` | Fact Table | Sales transactions with surrogate key joins |

---

## 🚀 How To Run This Project

> **Prerequisites:** SQL Server installed, SSMS or Azure Data Studio connected to your instance (e.g., `.\SQLEXPRESS02`). Run as a user with `sysadmin` or `dbcreator` permissions.

Follow these steps **in order**:

**Step 1 — Initialize the Database**
```sql
-- Run: scripts/init_database.sql
-- Creates the DataWarehouse database and Bronze, Silver, Gold schemas
```

**Step 2 — Create Bronze Tables**
```sql
-- Run: scripts/bronze/ddl_bronze.SQL
-- Sets up all raw staging tables
```

**Step 3 — Load Bronze Data**
```sql
-- Run: scripts/bronze/proc_load_bronze.SQL
-- Executes the stored procedure to bulk load source CSV data
```

**Step 4 — Create Silver Tables**
```sql
-- Run: scripts/silver/ddl_silver.sql
-- Sets up cleansed tables with audit columns
```

**Step 5 — Load Silver Data**
```sql
-- Run: scripts/silver/proc_load_silver.sql
-- Transforms and loads data from Bronze → Silver
```

**Step 6 — Create Gold Views**
```sql
-- Run: scripts/gold/gold_layer_views.sql
-- Creates the final Star Schema views for reporting
```

**Step 7 — Validate Data Quality**
```sql
-- Run: tests/quality_check_silver.SQL
-- Expectation: All checks return 0 rows (zero anomalies)
```

---

## ✅ Data Quality Checks

The `tests/quality_check_silver.SQL` script validates the Silver layer after every load. Checks include:

- 🔍 No NULL or duplicate primary keys
- 🔍 No unwanted whitespace in key fields
- 🔍 Mathematical consistency: `sales = quantity × price`
- 🔍 Logical date ordering: order date before ship/due date
- 🔍 Valid birthdate ranges (1924 → present)
- 🔍 Standardized country names and category labels

> **Goal:** Every check should return **zero rows**. Any result means the load procedure needs adjustment.

---

## 👤 Author

**Samarth Bansal**
Built as part of a hands-on Data Engineering project.

---

## 📄 License

This project is licensed under the terms in the [LICENSE](LICENSE) file.
