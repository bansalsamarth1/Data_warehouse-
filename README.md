Create a clean, professional Entity Relationship Diagram (ERD) 
showing a Star Schema for a data warehouse. White background, 
modern minimal style.

There is 1 FACT TABLE in the center and 2 DIMENSION TABLES on the sides.

FACT TABLE (center, highlight in gold/yellow color):
- Table name: "fact_sales"
- Columns:
  * order_number (VARCHAR)
  * product_key (INT) [FK]
  * customer_key (INT) [FK]
  * order_date (DATE)
  * shipping_date (DATE)
  * due_date (DATE)
  * sales_amount (INT)
  * quantity (INT)
  * price (INT)

DIMENSION TABLE 1 (left side, light blue color):
- Table name: "dim_customers"
- Columns:
  * customer_key (INT) [PK]
  * customer_id (INT)
  * customer_number (VARCHAR)
  * first_name (VARCHAR)
  * last_name (VARCHAR)
  * country (VARCHAR)
  * marital_status (VARCHAR)
  * gender (VARCHAR)
  * birthdate (DATE)
  * create_date (DATE)

DIMENSION TABLE 2 (right side, light green color):
- Table name: "dim_products"
- Columns:
  * product_key (INT) [PK]
  * product_id (INT)
  * product_number (VARCHAR)
  * product_name (VARCHAR)
  * category_id (VARCHAR)
  * category (VARCHAR)
  * subcategory (VARCHAR)
  * maintenance (VARCHAR)
  * cost (INT)
  * product_line (VARCHAR)
  * start_date (DATETIME)

RELATIONSHIPS:
- Draw a line from dim_customers.customer_key (PK) 
  to fact_sales.customer_key (FK), label it "1 to Many"
- Draw a line from dim_products.product_key (PK) 
  to fact_sales.product_key (FK), label it "1 to Many"

Use classic ERD styling with proper table headers, 
column rows, PK/FK labels clearly marked. 
Add a title at top: "Gold Layer - Star Schema (ERD)"
