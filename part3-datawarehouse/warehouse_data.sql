-- warehouse_data.sql
-- Database: fleximart_dw

SET FOREIGN_KEY_CHECKS = 1;

-- =========================
-- dim_date (30 rows: Jan-Feb 2024)
-- =========================
INSERT INTO dim_date (date_key, full_date, day_of_week, day_of_month, month, month_name, quarter, year, is_weekend) VALUES
(20240115,'2024-01-15','Monday',15,1,'January','Q1',2024,FALSE),
(20240116,'2024-01-16','Tuesday',16,1,'January','Q1',2024,FALSE),
(20240117,'2024-01-17','Wednesday',17,1,'January','Q1',2024,FALSE),
(20240118,'2024-01-18','Thursday',18,1,'January','Q1',2024,FALSE),
(20240119,'2024-01-19','Friday',19,1,'January','Q1',2024,FALSE),
(20240120,'2024-01-20','Saturday',20,1,'January','Q1',2024,TRUE),
(20240121,'2024-01-21','Sunday',21,1,'January','Q1',2024,TRUE),
(20240122,'2024-01-22','Monday',22,1,'January','Q1',2024,FALSE),
(20240123,'2024-01-23','Tuesday',23,1,'January','Q1',2024,FALSE),
(20240124,'2024-01-24','Wednesday',24,1,'January','Q1',2024,FALSE),
(20240125,'2024-01-25','Thursday',25,1,'January','Q1',2024,FALSE),
(20240126,'2024-01-26','Friday',26,1,'January','Q1',2024,FALSE),
(20240127,'2024-01-27','Saturday',27,1,'January','Q1',2024,TRUE),
(20240128,'2024-01-28','Sunday',28,1,'January','Q1',2024,TRUE),
(20240129,'2024-01-29','Monday',29,1,'January','Q1',2024,FALSE),

(20240201,'2024-02-01','Thursday',1,2,'February','Q1',2024,FALSE),
(20240202,'2024-02-02','Friday',2,2,'February','Q1',2024,FALSE),
(20240203,'2024-02-03','Saturday',3,2,'February','Q1',2024,TRUE),
(20240204,'2024-02-04','Sunday',4,2,'February','Q1',2024,TRUE),
(20240205,'2024-02-05','Monday',5,2,'February','Q1',2024,FALSE),
(20240206,'2024-02-06','Tuesday',6,2,'February','Q1',2024,FALSE),
(20240207,'2024-02-07','Wednesday',7,2,'February','Q1',2024,FALSE),
(20240208,'2024-02-08','Thursday',8,2,'February','Q1',2024,FALSE),
(20240209,'2024-02-09','Friday',9,2,'February','Q1',2024,FALSE),
(20240210,'2024-02-10','Saturday',10,2,'February','Q1',2024,TRUE),
(20240211,'2024-02-11','Sunday',11,2,'February','Q1',2024,TRUE),
(20240212,'2024-02-12','Monday',12,2,'February','Q1',2024,FALSE),
(20240213,'2024-02-13','Tuesday',13,2,'February','Q1',2024,FALSE),
(20240214,'2024-02-14','Wednesday',14,2,'February','Q1',2024,FALSE),
(20240215,'2024-02-15','Thursday',15,2,'February','Q1',2024,FALSE);

-- =========================
-- dim_product (15 rows, 3 categories)
-- =========================
INSERT INTO dim_product (product_id, product_name, category, subcategory, unit_price) VALUES
('P001','Samsung Galaxy S21','Electronics','Mobile',45999.00),
('P003','Apple MacBook Pro','Electronics','Laptop',52999.00),
('P007','HP Laptop','Electronics','Laptop',52999.00),
('P012','Dell Monitor 24inch','Electronics','Monitor',12999.00),
('P014','iPhone 13','Electronics','Mobile',69999.00),

('P002','Nike Running Shoes','Fashion','Footwear',3499.00),
('P004','Levi''s Jeans','Fashion','Clothing',2999.00),
('P008','Adidas T-Shirt','Fashion','Clothing',1299.00),
('P011','Puma Sneakers','Fashion','Footwear',4599.00),
('P020','Reebok Trackpants','Fashion','Clothing',1899.00),

('P006','Organic Almonds','Groceries','Dry Fruits',899.00),
('P009','Basmati Rice 5kg','Groceries','Staples',650.00),
('P015','Organic Honey 500g','Groceries','Staples',450.00),
('P018','Masoor Dal 1kg','Groceries','Staples',120.00),
('P010','OnePlus Nord','Electronics','Mobile',45999.00);

-- =========================
-- dim_customer (12 rows, 4+ cities)
-- =========================
INSERT INTO dim_customer (customer_id, customer_name, city, state, customer_segment) VALUES
('C001','Rahul Sharma','Bangalore','Karnataka','Retail'),
('C002','Priya Patel','Mumbai','Maharashtra','Retail'),
('C003','Amit Kumar','Delhi','Delhi','Retail'),
('C004','Sneha Reddy','Hyderabad','Telangana','Retail'),
('C005','Vikram Singh','Chennai','Tamil Nadu','Retail'),
('C006','Anjali Mehta','Bangalore','Karnataka','Corporate'),
('C007','Ravi Verma','Pune','Maharashtra','Retail'),
('C008','Pooja Iyer','Bangalore','Karnataka','Home Office'),
('C009','Karthik Nair','Kochi','Kerala','Retail'),
('C010','Deepa Gupta','Delhi','Delhi','Corporate'),
('C011','Arjun Rao','Hyderabad','Telangana','Retail'),
('C012','Lakshmi Krishnan','Chennai','Tamil Nadu','Home Office');

-- =========================
-- fact_sales (40 rows)
-- =========================
INSERT INTO fact_sales (date_key, product_key, customer_key, quantity_sold, unit_price, discount_amount, total_amount) VALUES
(20240120, 1, 2, 2, 45999.00, 0, 91998.00),
(20240121, 5, 1, 1, 69999.00, 2000.00, 67999.00),
(20240127, 3, 3, 2, 52999.00, 0, 105998.00),
(20240128, 2, 6, 1, 52999.00, 1500.00, 51499.00),
(20240203, 4, 10, 2, 12999.00, 0, 25998.00),
(20240204, 6, 7, 3, 3499.00, 0, 10497.00),
(20240210, 11, 12, 5, 899.00, 0, 4495.00),
(20240211, 12, 5, 6, 650.00, 0, 3900.00),
(20240115, 1, 1, 1, 45999.00, 0, 45999.00),
(20240116, 7, 2, 2, 2999.00, 0, 5998.00),
(20240117, 3, 3, 1, 52999.00, 0, 52999.00),
(20240118, 6, 4, 1, 3499.00, 0, 3499.00),
(20240119, 9, 9, 2, 4599.00, 0, 9198.00),
(20240122, 4, 6, 1, 12999.00, 0, 12999.00),
(20240123, 8, 8, 4, 1299.00, 0, 5196.00),
(20240124, 13, 2, 3, 450.00, 0, 1350.00),
(20240125, 10, 7, 2, 1899.00, 0, 3798.00),
(20240126, 6, 11, 1, 3499.00, 0, 3499.00),
(20240129, 12, 5, 8, 650.00, 0, 5200.00),
(20240201, 11, 1, 2, 899.00, 0, 1798.00),
(20240202, 5, 2, 1, 69999.00, 0, 69999.00),
(20240205, 2, 3, 1, 52999.00, 0, 52999.00),
(20240206, 14, 4, 10, 120.00, 0, 1200.00),
(20240207, 1, 6, 1, 45999.00, 0, 45999.00),
(20240208, 15, 7, 1, 45999.00, 0, 45999.00),
(20240209, 9, 8, 1, 4599.00, 0, 4599.00),
(20240212, 7, 9, 2, 2999.00, 0, 5998.00),
(20240213, 6, 10, 2, 3499.00, 0, 6998.00),
(20240214, 4, 11, 1, 12999.00, 0, 12999.00),
(20240116, 1, 2, 1, 45999.00, 0, 45999.00),
(20240118, 12, 5, 5, 650.00, 0, 3250.00),
(20240120, 7, 6, 3, 2999.00, 0, 8997.00),
(20240121, 8, 8, 2, 1299.00, 0, 2598.00),
(20240125, 11, 12, 4, 899.00, 0, 3596.00),
(20240203, 3, 3, 1, 52999.00, 0, 52999.00),
(20240204, 6, 7, 2, 3499.00, 0, 6998.00),
(20240210, 5, 1, 1, 69999.00, 0, 69999.00),
(20240211, 14, 9, 12, 120.00, 0, 1440.00),
(20240212, 10, 4, 2, 1899.00, 0, 3798.00),
(20240215, 12, 2, 4, 650.00, 0, 2600.00);
