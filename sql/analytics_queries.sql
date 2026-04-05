USE smart_food;
-- Query A
SELECT c.customer_id, c.name, SUM(o.total_amount) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC
LIMIT 10;
-- Query B
SELECT mi.item_id, mi.name AS item_name, COUNT(oi.order_item_id) AS order_count
FROM order_items oi
JOIN menu_items mi ON oi.item_id = mi.item_id
GROUP BY mi.item_id, mi.name
ORDER BY order_count DESC
LIMIT 10;
-- Query C
SELECT r.restaurant_id, r.name AS restaurant_name, 
       AVG(o.total_amount) AS avg_order_value
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.name
ORDER BY avg_order_value DESC;
-- Query D
SELECT d.driver_id, d.name AS driver_name, COUNT(del.delivery_id) AS deliveries_completed
FROM deliveries del
JOIN drivers d ON del.driver_id = d.driver_id
WHERE del.status = 'DELIVERED'
GROUP BY d.driver_id, d.name
ORDER BY deliveries_completed DESC;
-- Query E
SELECT o.order_id, c.name AS customer, r.name AS restaurant,
       mi.name AS item_name, oi.quantity, oi.item_price
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
JOIN menu_items mi ON oi.item_id = mi.item_id
ORDER BY o.order_id, mi.name;
-- Query F
SELECT method AS payment_method, COUNT(payment_id) AS number_of_payments,
       SUM(amount) AS total_amount_processed
FROM payments
GROUP BY method
ORDER BY total_amount_processed DESC;
