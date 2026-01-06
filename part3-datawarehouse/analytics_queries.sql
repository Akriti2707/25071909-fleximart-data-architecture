-- Query 1: Monthly Sales Drill-Down Analysis
-- Business Scenario: "The CEO wants to see sales performance broken down by time periods.
-- Start with yearly total, then quarterly, then monthly sales for 2024."
-- Demonstrates: Drill-down (Year → Quarter → Month)

SELECT
    d.year,
    d.quarter,
    d.month_name,
    ROUND(SUM(f.total_amount), 2) AS total_sales,
    SUM(f.quantity_sold) AS total_quantity
FROM fact_sales f
JOIN dim_date d
    ON d.date_key = f.date_key
WHERE d.year = 2024
GROUP BY
    d.year, d.quarter, d.month, d.month_name
ORDER BY
    d.year, d.quarter, d.month;


-- Query 2: Top 10 Products by Revenue
-- Business Scenario: "Show the top 10 products by revenue, along with category,
-- total units sold, and revenue contribution percentage."
-- Includes: Revenue percentage calculation

WITH product_rev AS (
    SELECT
        p.product_name,
        p.category,
        SUM(f.quantity_sold) AS units_sold,
        ROUND(SUM(f.total_amount), 2) AS revenue
    FROM fact_sales f
    JOIN dim_product p
        ON p.product_key = f.product_key
    GROUP BY
        p.product_key, p.product_name, p.category
)
SELECT
    product_name,
    category,
    units_sold,
    revenue,
    ROUND((revenue / SUM(revenue) OVER ()) * 100, 2) AS revenue_percentage
FROM product_rev
ORDER BY
    revenue DESC
LIMIT 10;


-- Query 3: Customer Segmentation Analysis
-- Business Scenario: "Segment customers into High Value (>₹50,000),
-- Medium Value (₹20,000–₹50,000), and Low Value (<₹20,000).
-- Show count of customers and total revenue in each segment."
-- Segments: High / Medium / Low value customers

WITH customer_totals AS (
    SELECT
        c.customer_key,
        c.customer_name,
        ROUND(SUM(f.total_amount), 2) AS total_spent
    FROM fact_sales f
    JOIN dim_customer c
        ON c.customer_key = f.customer_key
    GROUP BY
        c.customer_key, c.customer_name
),
segmented AS (
    SELECT
        CASE
            WHEN total_spent > 50000 THEN 'High Value'
            WHEN total_spent >= 20000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment,
        total_spent
    FROM customer_totals
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_spent), 2) AS total_revenue,
    ROUND(AVG(total_spent), 2) AS avg_revenue_per_customer
FROM segmented
GROUP BY customer_segment
ORDER BY
    CASE customer_segment
        WHEN 'High Value' THEN 1
        WHEN 'Medium Value' THEN 2
        ELSE 3
    END;
