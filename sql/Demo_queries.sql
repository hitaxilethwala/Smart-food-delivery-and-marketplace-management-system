-- =========================================================
-- Smart Food Delivery & Marketplace Management System
-- Demo Queries for Presentation (MySQL Workbench)
-- Run AFTER the database + data script (SQL(1).sql)
-- =========================================================

USE smart_food;

-- ---------------------------------------------------------
-- Q1 — Simple Query
-- Type: Simple SELECT
-- What it shows:
--   First 5 customers from the customers table.
-- ---------------------------------------------------------
SELECT customer_id, name, gender, account_type
FROM customers
ORDER BY customer_id
LIMIT 5;


-- ---------------------------------------------------------
-- Q2 — Top Customers by Total Spending
-- Type: Aggregate + INNER JOIN
-- Requirement covered: Aggregate, Inner Join
-- What it shows:
--   Top 10 customers based on total money spent on orders.
-- ---------------------------------------------------------
SELECT c.customer_id, c.name, SUM(o.total_amount) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC
LIMIT 10;


-- ---------------------------------------------------------
-- Q3 — Most Frequently Ordered Menu Items
-- Type: Aggregate + INNER JOIN
-- Requirement covered: Aggregate, Inner Join
-- What it shows:
--   Top 10 menu items by number of times they appear in order_items.
-- ---------------------------------------------------------
SELECT mi.item_id, mi.name AS item_name, COUNT(oi.order_item_id) AS order_count
FROM order_items oi
JOIN menu_items mi ON oi.item_id = mi.item_id
GROUP BY mi.item_id, mi.name
ORDER BY order_count DESC
LIMIT 10;


-- ---------------------------------------------------------
-- Q4 — Average Order Value per Restaurant
-- Type: Aggregate + INNER JOIN
-- Requirement covered: Aggregate, Inner Join
-- What it shows:
--   Average total_amount of orders for each restaurant.
-- ---------------------------------------------------------
SELECT r.restaurant_id,
       r.name AS restaurant_name,
       AVG(o.total_amount) AS avg_order_value
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.name
ORDER BY avg_order_value DESC;


-- ---------------------------------------------------------
-- Q5 — Deliveries Completed by Each Driver
-- Type: Aggregate + INNER JOIN
-- Requirement covered: Aggregate, Inner Join
-- What it shows:
--   Number of DELIVERED orders handled by each driver.
-- ---------------------------------------------------------
SELECT d.driver_id,
       d.name AS driver_name,
       COUNT(del.delivery_id) AS deliveries_completed
FROM deliveries del
JOIN drivers d ON del.driver_id = d.driver_id
WHERE del.status = 'DELIVERED'
GROUP BY d.driver_id, d.name
ORDER BY deliveries_completed DESC;


-- ---------------------------------------------------------
-- Q6 — Detailed Breakdown of Each Order with Items
-- Type: Multi-table INNER JOIN
-- Requirement covered: Inner Join
-- What it shows:
--   For each order: customer, restaurant, item name, quantity, and item price.
-- ---------------------------------------------------------
SELECT o.order_id,
       c.name AS customer,
       r.name AS restaurant,
       mi.name AS item_name,
       oi.quantity,
       oi.item_price
FROM order_items oi
JOIN orders o       ON oi.order_id = o.order_id
JOIN customers c    ON o.customer_id = c.customer_id
JOIN restaurants r  ON o.restaurant_id = r.restaurant_id
JOIN menu_items mi  ON oi.item_id = mi.item_id
ORDER BY o.order_id, mi.name;


-- ---------------------------------------------------------
-- Q7 — Payment Method Usage Summary
-- Type: Aggregate
-- Requirement covered: Aggregate
-- What it shows:
--   Count of payments and total amount processed per payment method.
-- ---------------------------------------------------------
SELECT method AS payment_method,
       COUNT(payment_id) AS number_of_payments,
       SUM(amount) AS total_amount_processed
FROM payments
GROUP BY method
ORDER BY total_amount_processed DESC;


-- ---------------------------------------------------------
-- Q8 — Restaurant(s) with Highest Average Order Value
-- Type: Nested query + Aggregate + INNER JOIN
-- Requirement covered: Nested Query, >= ALL
-- What it shows:
--   Restaurant(s) whose average order value is >= every other restaurant’s average.
--   Demonstrates use of >= ALL inside HAVING.
-- ---------------------------------------------------------
SELECT 
    r.restaurant_id,
    r.name AS restaurant_name,
    AVG(o.total_amount) AS avg_order_value
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.name
HAVING AVG(o.total_amount) >= ALL (
    SELECT AVG(o2.total_amount)
    FROM orders o2
    GROUP BY o2.restaurant_id
);


-- ---------------------------------------------------------
-- Q9 — Customers Who Have Used a Promotion At Least Once
-- Type: Correlated Subquery + EXISTS
-- Requirement covered: Correlated Query, EXISTS
-- What it shows:
--   Customers who placed at least one order with a non-NULL promo_id.
-- ---------------------------------------------------------
SELECT DISTINCT c.customer_id, c.name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id   -- correlated to outer query
      AND o.promo_id IS NOT NULL
);


-- ---------------------------------------------------------
-- Q10 — All People on the Platform (Customers + Drivers)
-- Type: Set Operation (UNION)
-- Requirement covered: UNION
-- What it shows:
--   Combined list of customer names and driver names, labeled by role.
-- ---------------------------------------------------------
SELECT name, 'CUSTOMER' AS role
FROM customers
UNION
SELECT name, 'DRIVER' AS role
FROM drivers;


-- ---------------------------------------------------------
-- Q11 — Daily Order Stats with Percentage of All Orders
-- Type: Subquery in FROM + Subquery in SELECT + Aggregate
-- Requirement covered: Subqueries in SELECT and FROM
-- What it shows:
--   For each order_date:
--     - total_orders
--     - total_revenue
--     - percentage of total orders across all days.
-- ---------------------------------------------------------
SELECT
    d.order_date,
    d.total_orders,
    d.total_revenue,
    ROUND(
        100.0 * d.total_orders / (SELECT COUNT(*) FROM orders),
        2
    ) AS pct_of_all_orders
FROM (
    SELECT 
        DATE(order_time) AS order_date,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS total_revenue
    FROM orders
    GROUP BY DATE(order_time)
) AS d
ORDER BY d.order_date;
