# FlexiMart Schema Documentation

## 1) Entity–Relationship Description
The FlexiMart operational database contains four entities:

- **customers**: stores customer details.
- **products**: stores product catalog information.
- **orders**: stores order headers placed by customers.
- **order_items**: stores line items for each order (products within an order).

### Relationships
- **customers (1) → (M) orders**  
  One customer can place many orders.
- **orders (1) → (M) order_items**  
  One order can contain many order items.
- **products (1) → (M) order_items**  
  One product can appear in many order items.

---

## 2) ENTITY: customers
**Purpose:** Stores customer information.

**Attributes:**
- **customer_id**: Unique identifier (Primary Key, auto-increment)
- **first_name**: Customer’s first name
- **last_name**: Customer’s last name
- **email**: Customer email (UNIQUE, NOT NULL)
- **phone**: Customer phone number (standardized format)
- **city**: Customer city
- **registration_date**: Date the customer registered

**Relationships:**
- One customer can place **many** orders (1:M with orders).

---

## 3) ENTITY: products
**Purpose:** Stores product details and inventory.

**Attributes:**
- **product_id**: Unique identifier (Primary Key, auto-increment)
- **product_name**: Name of the product
- **category**: Product category (standardized naming)
- **price**: Product price (NOT NULL)
- **stock_quantity**: Units available (DEFAULT 0)

**Relationships:**
- One product can appear in **many** order items (1:M with order_items).

---

## 4) ENTITY: orders
**Purpose:** Stores order header details.

**Attributes:**
- **order_id**: Unique identifier (Primary Key, auto-increment)
- **customer_id**: Customer who placed the order (Foreign Key → customers.customer_id)
- **order_date**: Date of the order (NOT NULL)
- **total_amount**: Total order amount (NOT NULL)
- **status**: Order status (DEFAULT 'Pending')

**Relationships:**
- Many orders belong to one customer (M:1 with customers).
- One order has many order items (1:M with order_items).

---

## 5) ENTITY: order_items
**Purpose:** Stores individual items within each order.

**Attributes:**
- **order_item_id**: Unique identifier (Primary Key, auto-increment)
- **order_id**: The order this item belongs to (Foreign Key → orders.order_id)
- **product_id**: The product purchased (Foreign Key → products.product_id)
- **quantity**: Quantity purchased (NOT NULL)
- **unit_price**: Unit price at purchase time (NOT NULL)
- **subtotal**: quantity × unit_price (NOT NULL)

---

## 6) Normalization Explanation (3NF)
This database is in Third Normal Form (3NF) because each table contains attributes that depend only on the table’s primary key, and there are no partial or transitive dependencies within a table. In the **customers** table, all non-key attributes (first_name, last_name, email, phone, city, registration_date) depend only on customer_id. In the **products** table, product_name, category, price, and stock_quantity depend only on product_id. In the **orders** table, customer_id, order_date, total_amount, and status depend only on order_id. In the **order_items** table, order_id, product_id, quantity, unit_price, and subtotal depend only on order_item_id.

Functional dependencies include:  
customer_id → first_name, last_name, email, phone, city, registration_date  
product_id → product_name, category, price, stock_quantity  
order_id → customer_id, order_date, total_amount, status  
order_item_id → order_id, product_id, quantity, unit_price, subtotal

This design avoids update anomalies by storing customer and product information once instead of repeating them across orders. It avoids insert anomalies because customers and products can exist without needing an order. It avoids delete anomalies because deleting an order does not remove the customer or product master data. The many-to-many relationship between orders and products is resolved using **order_items**, preventing repeating groups and keeping facts stored at the correct grain.

---

## 7) Sample Data Representation

### customers
| customer_id | first_name | last_name | email                       | phone          | city      | registration_date |
|------------:|------------|-----------|-----------------------------|----------------|-----------|-------------------|
| 1           | Amit       | Kumar     | amit.kumar.c003@example.com | +91-9765432109 | Delhi     | 2023-03-10        |
| 2           | Anjali     | Mehta     | anjali.mehta@gmail.com      | +91-9876543210 | Bangalore | 2023-06-18        |
| 3           | Arjun      | Rao       | arjun.rao@gmail.com         | +91-9876509876 | Hyderabad | 2023-11-05        |

### products
| product_id | product_name       | category    | price    | stock_quantity |
|-----------:|--------------------|-------------|---------:|---------------:|
| 1          | Samsung Galaxy S21 | Electronics | 45999.00 | 150            |
| 2          | Nike Running Shoes | Fashion     | 3499.00  | 80             |
| 3          | Apple MacBook Pro  | Electronics | 32999.00 | 45             |

### orders
| order_id | customer_id | order_date  | total_amount | status    |
|---------:|------------:|-------------|-------------:|-----------|
| 1        | 17          | 2024-01-15  | 45999.00     | Completed |
| 2        | 15          | 2024-01-16  | 5998.00      | Completed |
| 3        | 1           | 2024-01-15  | 52999.00     | Completed |

### order_items
| order_item_id | order_id | product_id | quantity | unit_price | subtotal  |
|--------------:|---------:|-----------:|---------:|-----------:|----------:|
| 1             | 1        | 1          | 1        | 45999.00   | 45999.00  |
| 2             | 2        | 4          | 2        | 2999.00    | 5998.00   |
| 3             | 3        | 7          | 1        | 52999.00   | 52999.00  |

