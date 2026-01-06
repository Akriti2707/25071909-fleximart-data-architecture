# Star Schema Design - FlexiMart Data Warehouse

## Section 1: Schema Overview

### FACT TABLE: fact_sales
**Grain:** One row per product per order line item (transaction line-item level).  
**Business Process:** Sales transactions (orders and items).

**Measures (Numeric Facts):**
- **quantity_sold:** Number of units sold in the line item
- **unit_price:** Price per unit at the time of sale
- **discount_amount:** Discount applied on the line (default 0 if not provided)
- **total_amount:** Final line total (quantity_sold × unit_price − discount_amount)

**Foreign Keys:**
- **date_key → dim_date**
- **product_key → dim_product**
- **customer_key → dim_customer**

---

### DIMENSION TABLE: dim_date
**Purpose:** Enables time-based analysis (daily, monthly, quarterly, yearly).  
**Type:** Conformed time dimension.

**Attributes:**
- **date_key (PK):** Surrogate key as integer in YYYYMMDD format (e.g., 20240115)
- **full_date:** Actual date (YYYY-MM-DD)
- **day_of_week:** Monday, Tuesday, etc.
- **day_of_month:** 1–31
- **month:** 1–12
- **month_name:** January, February, etc.
- **quarter:** Q1, Q2, Q3, Q4
- **year:** 2023, 2024, etc.
- **is_weekend:** TRUE for Saturday/Sunday, otherwise FALSE

---

### DIMENSION TABLE: dim_product
**Purpose:** Describes products for reporting by category/subcategory and pricing.

**Attributes:**
- **product_key (PK):** Surrogate key (auto-increment)
- **product_id:** Natural/business product ID from source (e.g., P001)
- **product_name:** Product name
- **category:** Main category (Electronics, Fashion, Groceries, etc.)
- **subcategory:** Optional finer grouping (can be NULL if not available)
- **unit_price:** Standard/current unit price (for reference; fact_sales stores transaction unit_price)

---

### DIMENSION TABLE: dim_customer
**Purpose:** Describes customers for segmentation and city/state reporting.

**Attributes:**
- **customer_key (PK):** Surrogate key (auto-increment)
- **customer_id:** Natural/business customer ID from source (e.g., C001)
- **customer_name:** Full name (first + last)
- **city:** Customer city
- **state:** Customer state (can be NULL if not available)
- **customer_segment:** Segment label (e.g., Retail/Corporate/Home Office, or Basic/Gold/etc. if defined)

---

## Section 2: Design Decisions

The fact table uses a line-item grain because it matches how sales are recorded at the most detailed level: each product purchased within an order. This granularity supports flexible analysis such as product-level revenue, category trends, and customer spending patterns without losing detail. Aggregations (daily → monthly → quarterly) can be computed reliably from this base.

Surrogate keys are used in the warehouse dimensions (date_key, product_key, customer_key) because they provide stable, numeric identifiers that remain consistent even if source system IDs change or get re-formatted. Surrogate keys also improve join performance and simplify handling of slowly changing dimension fields in the future (for example, if a customer changes city or a product changes category).

This model supports drill-down and roll-up because dimensions store hierarchical attributes (month → quarter → year, product → category, customer → city/state/segment). Analysts can start from high-level summaries and drill into specific products, customers, or time periods using the same fact table.

---

## Section 3: Sample Data Flow

**Source Transaction (example):**  
Order #101, Customer “John Doe”, Product “Laptop”, Qty: 2, Price: 50000

**Becomes in Data Warehouse:**

**fact_sales (one row for the line item):**
- date_key: 20240115  
- product_key: 5  
- customer_key: 12  
- quantity_sold: 2  
- unit_price: 50000  
- discount_amount: 0  
- total_amount: 100000  

**dim_date:**
- date_key: 20240115  
- full_date: 2024-01-15  
- month: 1  
- month_name: January  
- quarter: Q1  
- year: 2024  
- is_weekend: FALSE  

**dim_product:**
- product_key: 5  
- product_id: P007  
- product_name: Laptop  
- category: Electronics  
- unit_price: 50000  

**dim_customer:**
- customer_key: 12  
- customer_id: C020  
- customer_name: John Doe  
- city: Mumbai  
- customer_segment: Retail
