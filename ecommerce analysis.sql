-- ============================================================
-- PROJECT: E-Commerce Sales Analysis
-- Tool: PostgreSQL
-- Author: Lewis Brian
-- Description: Sales performance analysis across customers,
--              products, and orders for an online retail store.
-- ============================================================


-- ============================================================
-- STEP 1: CREATE TABLES
-- ============================================================
-- We need three tables. The orders table references both
-- customers and products via foreign keys, so create those two first.

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(50),
    last_name     VARCHAR(50),
    city          VARCHAR(50),
    join_date     DATE
);

CREATE TABLE products (
    product_id    SERIAL PRIMARY KEY,
    product_name  VARCHAR(100),
    category      VARCHAR(50),
    price         NUMERIC(10, 2)
);

-- orders references both tables above, so it goes last
CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    customer_id   INT REFERENCES customers(customer_id),
    product_id    INT REFERENCES products(product_id),
    quantity      INT,
    order_date    DATE
);


-- ============================================================
-- STEP 2: IMPORT DATA
-- ============================================================
-- After creating the tables, import the CSV files using
-- pgAdmin: right-click each table → Import/Export Data →
-- select the CSV → toggle Header ON → click OK.
--
-- Import order matters because of foreign keys:
--   1. customers.csv
--   2. products.csv
--   3. orders.csv


-- ============================================================
-- STEP 3: EXPLORE THE DATA
-- ============================================================
-- Always look at what you're working with before jumping
-- into analysis. Check for obvious issues, unexpected values,
-- or missing data.

-- Preview each table
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;

-- Row counts per table
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_products  FROM products;
SELECT COUNT(*) AS total_orders    FROM orders;


-- ============================================================
-- STEP 4: TOTAL REVENUE PER PRODUCT
-- ============================================================
-- Join orders to products so we can calculate revenue.
-- Revenue = quantity × price. We rank by highest revenue first.

SELECT
    p.product_name,
    p.category,
    SUM(o.quantity)           AS total_units_sold,
    SUM(o.quantity * p.price) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC;


-- ============================================================
-- STEP 5: TOP 5 CUSTOMERS BY TOTAL SPEND
-- ============================================================
-- We need two JOINs here: one to get the customer's name,
-- and another to get the product price so we can calculate spend.

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    c.city,
    COUNT(o.order_id)                  AS total_orders,
    SUM(o.quantity * p.price)          AS total_spend
FROM customers c
JOIN orders   o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id  = p.product_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.city
ORDER BY total_spend DESC
LIMIT 5;


-- ============================================================
-- STEP 6: MONTHLY REVENUE TREND
-- ============================================================
-- TO_CHAR formats the date into a readable YYYY-MM string
-- so we can group by month and see if revenue is growing.

SELECT
    TO_CHAR(o.order_date, 'YYYY-MM') AS month,
    COUNT(o.order_id)                AS number_of_orders,
    SUM(o.quantity * p.price)        AS monthly_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY month;


-- ============================================================
-- STEP 7: REVENUE BY CATEGORY WITH PERCENTAGE SHARE (CTE)
-- ============================================================
-- A CTE (WITH clause) lets us calculate category totals first,
-- then reference those totals to add a percentage column.
-- SUM() OVER () without PARTITION BY gives the grand total
-- across all rows, which we divide into to get the share.

WITH category_revenue AS (
    SELECT
        p.category,
        SUM(o.quantity * p.price) AS total_revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category
)
SELECT
    category,
    total_revenue,
    ROUND(
        total_revenue / SUM(total_revenue) OVER () * 100, 2
    ) AS revenue_percentage
FROM category_revenue
ORDER BY total_revenue DESC;


-- ============================================================
-- STEP 8: RANK CUSTOMERS BY SPEND (WINDOW FUNCTION)
-- ============================================================
-- RANK() assigns position 1 to the highest spender.
-- Unlike GROUP BY, window functions don't collapse rows —
-- each customer keeps their own row with a rank attached.

SELECT
    c.first_name || ' ' || c.last_name AS full_name,
    c.city,
    SUM(o.quantity * p.price)          AS total_spend,
    RANK() OVER (
        ORDER BY SUM(o.quantity * p.price) DESC
    )                                  AS spend_rank
FROM customers c
JOIN orders   o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id  = p.product_id
GROUP BY c.first_name, c.last_name, c.city
ORDER BY spend_rank;


-- ============================================================
-- STEP 9: CUSTOMER SPEND TIERS (CASE WHEN)
-- ============================================================
-- CASE WHEN works like an IF/ELSE. Here we segment customers
-- into three value tiers based on their total spend.
-- Useful for targeting loyalty programmes or marketing campaigns.

SELECT
    c.first_name || ' ' || c.last_name AS full_name,
    SUM(o.quantity * p.price)          AS total_spend,
    CASE
        WHEN SUM(o.quantity * p.price) >= 400 THEN 'High Value'
        WHEN SUM(o.quantity * p.price) >= 200 THEN 'Mid Value'
        ELSE 'Low Value'
    END                                AS customer_tier
FROM customers c
JOIN orders   o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id  = p.product_id
GROUP BY c.first_name, c.last_name
ORDER BY total_spend DESC;
