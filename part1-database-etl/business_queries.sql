-- Query 1: Customer Purchase History
-- Business Question: "Generate a detailed report showing each customer's name, email,
-- total number of orders placed, and total amount spent. Include only customers who
-- have placed at least 2 orders and spent more than ₹5,000. Order by total amount spent DESC."
-- Expected to return customers with 2+ orders and >5000 spent

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.subtotal), 2) AS total_spent
FROM customers c
JOIN orders o
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON oi.order_id = o.order_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, c.email
HAVING
    COUNT(DISTINCT o.order_id) >= 2
    AND SUM(oi.subtotal) > 5000
ORDER BY
    total_spent DESC;


-- Query 2: Product Sales Analysis
-- Business Question: "For each product category, show category name, number of different products sold,
-- total quantity sold, and total revenue generated. Only include categories with > ₹10,000 revenue.
-- Order by revenue DESC."
-- Expected to return categories with >10000 revenue

SELECT
    p.category AS category,
    COUNT(DISTINCT oi.product_id) AS num_products,
    SUM(oi.quantity) AS total_quantity_sold,
    ROUND(SUM(oi.subtotal), 2) AS total_revenue
FROM products p
JOIN order_items oi
    ON oi.product_id = p.product_id
GROUP BY
    p.category
HAVING
    SUM(oi.subtotal) > 10000
ORDER BY
    total_revenue DESC;


-- Query 3: Monthly Sales Trend
-- Business Question: "Show monthly sales trends for the year 2024.
-- For each month, display the month name, total number of orders, total revenue,
-- and the running total of revenue (cumulative from January to that month)."
-- Expected to show monthly and cumulative revenue for 2024 only

WITH monthly AS (
    SELECT
        MONTH(order_date) AS month_num,
        MONTHNAME(order_date) AS month_name,
        COUNT(*) AS total_orders,
        ROUND(SUM(total_amount), 2) AS monthly_revenue
    FROM orders
    WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01'
    GROUP BY MONTH(order_date), MONTHNAME(order_date)
)
SELECT
    month_name,
    total_orders,
    monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (ORDER BY month_num), 2) AS cumulative_revenue
FROM monthly
ORDER BY month_num;

