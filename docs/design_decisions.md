# 🧠 Design Decisions & Known Issues
### Data Warehouse — Medallion Architecture

> This document explains the *why* behind key architectural and implementation choices,
> and honestly documents known limitations of the current build.
> Reading this alongside the Data Dictionary gives a complete picture of the system.

---

## ✅ Design Decisions

---

### 1. Medallion Architecture (Bronze → Silver → Gold)

**Decision:** Structure the warehouse into three progressive layers rather than loading directly into a final schema.

**Why:**
- **Bronze** acts as a raw audit trail — if transformation logic needs to change, we never lose the original data
- **Silver** isolates all cleansing logic in one place — easier to debug, test, and update
- **Gold** stays clean and stable for reporting — business users and BI tools only ever touch Gold
- Each layer can be reloaded independently without affecting the others

---

### 2. Full Load Strategy (TRUNCATE + INSERT)

**Decision:** Every pipeline run truncates the target table and reloads all data from scratch.

**Why:**
- Simpler to implement and reason about than incremental/delta loading
- Guarantees idempotency — running the procedure 10 times produces the same result as running it once
- Appropriate for the current data volume

**Trade-off:**
- Not suitable for very large datasets where full reloads become expensive
- A future improvement would be CDC (Change Data Capture) or watermark-based incremental loads

---

### 3. Surrogate Keys in the Gold Layer

**Decision:** Replace natural source keys (`cst_id`, `prd_id`) with system-generated surrogate keys (`customer_key`, `product_key`) using `ROW_NUMBER()`.

**Why:**
- Decouples the warehouse from source system changes — if the CRM renumbers customers, the warehouse is unaffected
- Industry standard for dimensional modelling
- Enables clean foreign key relationships in the Star Schema

**Trade-off:**
- Natural keys (`customer_id`, `product_id`) are retained alongside surrogates for traceability back to the source

---

### 4. CRM Takes Priority for Gender Resolution

**Decision:** When both CRM and ERP provide a gender value, CRM is always used. ERP is only a fallback when CRM returns `'n/a'`.

**Why:**
- CRM is the system of record for customer identity data
- ERP demographic data is supplementary and less maintained
- A clear priority rule prevents unpredictable merged values

**Implementation:**
```sql
CASE
    WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr  -- CRM priority
    ELSE COALESCE(ca.gen, 'n/a')                 -- ERP fallback
END AS gender
```

---

### 5. SCD Type 1 View in dim_products

**Decision:** The Gold `dim_products` view only exposes currently active products (`WHERE prd_end_dt IS NULL`). Historical product versions are stored in Silver but hidden from Gold.

**Why:**
- Most reporting use cases only need current product information
- Keeps the dimension clean and simple for BI tool users
- Historical product versions are preserved in Silver if ever needed

**Trade-off:**
- Sales transactions in `fact_sales` that reference discontinued products will have no matching dimension record — this is a known gap (see Known Issues below)

---

### 6. Date Fields Stay as INT Through Silver

**Decision:** Sales date columns (`sls_order_dt`, `sls_ship_dt`, `sls_due_dt`) are kept as integers (YYYYMMDD format) in both Bronze and Silver. They are only cast to `DATE` in the Gold fact view.

**Why:**
- Bronze must preserve raw source data exactly — the source sends integers
- Silver focuses on value corrections, not type changes for these fields
- `TRY_CAST` in Gold handles any malformed date integers safely without crashing the pipeline

**Implementation:**
```sql
TRY_CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) AS order_date
```

---

### 7. Sales Amount Recalculation Logic

**Decision:** If `sls_sales` is NULL, zero, or doesn't equal `quantity × price`, it is recalculated as `quantity × ABS(price)`.

**Why:**
- Source CRM data contains inconsistent financial values — likely due to manual data entry errors or system migration issues
- Enforcing `sales = quantity × price` as a business rule makes the fact table mathematically reliable

**Implementation:**
```sql
CASE
    WHEN sls_sales IS NULL OR sls_sales <= 0
      OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END
```

---

### 8. Product Key Prefix Stripping in fact_sales

**Decision:** The `FC-01-` prefix on `sls_prd_key` is stripped at join time in the Gold view rather than in Silver.

**Why:**
- Silver preserves the raw CRM sales key for auditability
- The stripping logic is simple (`SUBSTRING(sls_prd_key, 7, LEN(...))`) and belongs to the join logic, not the cleansing logic
- If the prefix ever changes, only the Gold view needs updating

---

## ⚠️ Known Issues & Limitations

---

### 1. Hardcoded File Paths in Bronze Load Procedure

**Issue:** The `bronze.load_bronze` stored procedure uses absolute file paths (e.g., `D:\data-warehouse\...`) for `BULK INSERT`.

**Impact:** The procedure will fail on any machine where the files are not located on the `D:\` drive at the exact same path.

**Fix:** Before running, update the file paths in `scripts/bronze/proc_load_bronze.SQL` to match your local environment. A future improvement would be to parameterise the base path.

---

### 2. Typo Preserved in Bronze Table

**Issue:** The column `cst_material_status` in `bronze.crm_cust_info` is a misspelling of `cst_marital_status`. This typo exists in the source CSV and is intentionally preserved in Bronze.

**Impact:** None — the correct column name (`cst_marital_status`) is used from Silver onward. The Bronze typo is purely cosmetic.

**Decision:** Bronze mirrors the source exactly, including its mistakes. Fixing typos is Silver's job.

---

### 3. Orphaned Sales Records for Discontinued Products

**Issue:** `gold.fact_sales` joins to `gold.dim_products` which filters out historical products (`WHERE prd_end_dt IS NULL`). Sales transactions that reference a discontinued product will produce a NULL `product_key` in the fact table.

**Impact:** Reports aggregating sales by product may silently undercount revenue if some sold products have since been discontinued.

**Recommended Fix:** Consider a separate `dim_products_history` view in Gold that includes all product versions, or use a bridge table approach for historical sales analysis.

---

### 4. No Incremental / Delta Loading

**Issue:** The pipeline uses a full TRUNCATE + reload strategy for every run.

**Impact:** As data volumes grow, load times will increase linearly. Currently acceptable, but not scalable for millions of rows.

**Recommended Fix:** Implement watermark-based incremental loading using `dwh_create_date` or source system timestamps.

---

### 5. Datasets Folder Requires Manual CSV Placement

**Issue:** The `datasets/` folder in this repo contains placeholder files. The actual source CSVs (`cust_info.csv`, `prd_info.csv`, etc.) must be placed manually before running the Bronze load.

**Impact:** The pipeline cannot run out of the box without the source data files.

**Fix:** Place source CSVs in the correct subfolders and update file paths in the Bronze procedure accordingly:
```
datasets/
├── source_crm/
│   ├── cust_info.csv
│   ├── prd_info.csv
│   └── sales_details.csv
└── source_erp/
    ├── CUST_AZ12.csv
    ├── LOC_A101.csv
    └── PX_CAT_G1V2.csv
```

---

### 6. No Primary Key Constraints Enforced in Bronze/Silver

**Issue:** Tables in Bronze and Silver do not have formal `PRIMARY KEY` or `UNIQUE` constraints defined at the database level. Data integrity is enforced by the load procedures and quality check scripts only.

**Impact:** A failed or partial load could leave duplicate rows that the database engine won't catch automatically.

**Recommended Fix:** Add `PRIMARY KEY` constraints to Silver tables after deduplication logic is confirmed stable. Bronze intentionally skips constraints to allow raw data through.

---

## 🗓️ Version History

| Version | Date | Author | Notes |
|---------|------|--------|-------|
| v1.0 | 2026-03-27 | Samarth Bansal | Initial Bronze & Silver layer build |
| v1.1 | 2026-03-28 | Samarth Bansal | Gold layer Star Schema views added, quality checks completed |
