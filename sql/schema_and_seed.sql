-- =========================================================
-- Smart Food Delivery & Marketplace Management System
-- MySQL 8.0.36 — clean, single-run script
-- Creates DB, tables, FKs, loads sample data, and shows outputs
-- No analysis queries (only basic SELECT previews).
-- =========================================================

-- 0) Fresh database
DROP DATABASE IF EXISTS smart_food;
CREATE DATABASE smart_food CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smart_food;

-- 1) Tables (based on the project proposal)
-- Customers
CREATE TABLE customers (
  customer_id   INT AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(100) NOT NULL,
  gender        ENUM('M','F','O') NULL,
  date_of_birth DATE NULL,
  phone_number  VARCHAR(20) UNIQUE,
  address       VARCHAR(255),
  account_type  ENUM('STANDARD','PREMIUM') DEFAULT 'STANDARD'
);

-- Restaurants
CREATE TABLE restaurants (
  restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(120) NOT NULL,
  cuisine_type  VARCHAR(60),
  location      VARCHAR(150),
  rating        DECIMAL(2,1) CHECK (rating >= 0 AND rating <= 5)
);

-- Menus (one per restaurant per effective date)
CREATE TABLE menus (
  menu_id       INT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id INT NOT NULL,
  effective_date DATE NOT NULL,
  CONSTRAINT fk_menu_restaurant
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
    ON DELETE CASCADE
);

-- Menu Items
CREATE TABLE menu_items (
  item_id   INT AUTO_INCREMENT PRIMARY KEY,
  menu_id   INT NOT NULL,
  name      VARCHAR(120) NOT NULL,
  price     DECIMAL(8,2) NOT NULL CHECK (price >= 0),
  availability TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT fk_item_menu
    FOREIGN KEY (menu_id) REFERENCES menus(menu_id)
    ON DELETE CASCADE
);

-- Promotions (optional per order)
CREATE TABLE promotions (
  promo_id  INT AUTO_INCREMENT PRIMARY KEY,
  code      VARCHAR(40) UNIQUE NOT NULL,
  discount_type ENUM('PERCENT','FLAT') NOT NULL,
  value     DECIMAL(8,2) NOT NULL,
  validity_start DATE NOT NULL,
  validity_end   DATE NOT NULL
);

-- Orders
CREATE TABLE orders (
  order_id      INT AUTO_INCREMENT PRIMARY KEY,
  customer_id   INT NOT NULL,
  restaurant_id INT NOT NULL,
  promo_id      INT NULL,
  order_time    DATETIME NOT NULL,
  total_amount  DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
  status        ENUM('PLACED','CONFIRMED','PREPARING','READY','OUT_FOR_DELIVERY','DELIVERED','CANCELLED')
               NOT NULL DEFAULT 'PLACED',
  CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT fk_orders_restaurant
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
  CONSTRAINT fk_orders_promo
    FOREIGN KEY (promo_id) REFERENCES promotions(promo_id)
);

-- Order Items (line items)
CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id      INT NOT NULL,
  item_id       INT NOT NULL,
  quantity      INT NOT NULL CHECK (quantity > 0),
  item_price    DECIMAL(8,2) NOT NULL CHECK (item_price >= 0),
  CONSTRAINT fk_oi_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_oi_item
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

-- Payments (exactly one per order)
CREATE TABLE payments (
  payment_id     INT AUTO_INCREMENT PRIMARY KEY,
  order_id       INT NOT NULL UNIQUE,
  method         ENUM('CARD','WALLET','CASH_ON_DELIVERY') NOT NULL,
  transaction_id VARCHAR(64),
  amount         DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
  status         ENUM('PENDING','SUCCESS','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
  CONSTRAINT fk_payment_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE
);

-- Drivers
CREATE TABLE drivers (
  driver_id INT AUTO_INCREMENT PRIMARY KEY,
  name      VARCHAR(100) NOT NULL,
  rating    DECIMAL(2,1) CHECK (rating >= 0 AND rating <= 5),
  contact   VARCHAR(30),
  status    ENUM('AVAILABLE','BUSY','OFFLINE') NOT NULL DEFAULT 'AVAILABLE'
);

-- Vehicles (0..1 per driver; 1 vehicle belongs to 1 driver)
CREATE TABLE vehicles (
  vehicle_id    INT AUTO_INCREMENT PRIMARY KEY,
  driver_id     INT UNIQUE, -- one-to-one
  type          ENUM('BIKE','SCOOTER','CAR') NOT NULL,
  license_plate VARCHAR(20) UNIQUE,
  CONSTRAINT fk_vehicle_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE SET NULL
);

-- Deliveries (one per order)
CREATE TABLE deliveries (
  delivery_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id    INT NOT NULL UNIQUE,
  driver_id   INT NOT NULL,
  pickup_time DATETIME,
  dropoff_time DATETIME,
  eta         INT, -- minutes
  status      ENUM('ASSIGNED','PICKED','EN_ROUTE','DELIVERED','FAILED','CANCELLED') NOT NULL DEFAULT 'ASSIGNED',
  CONSTRAINT fk_delivery_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_delivery_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

-- Reviews (customer reviews restaurant or driver)
CREATE TABLE reviews (
  review_id    INT AUTO_INCREMENT PRIMARY KEY,
  reviewer_id  INT NOT NULL,
  target_type  ENUM('RESTAURANT','DRIVER') NOT NULL,
  target_id    INT NOT NULL,
  rating       DECIMAL(2,1) NOT NULL CHECK (rating >= 0 AND rating <= 5),
  comment      VARCHAR(400),
  CONSTRAINT fk_review_customer
    FOREIGN KEY (reviewer_id) REFERENCES customers(customer_id)
);

-- 2) Seed Data (simple, deterministic — no sequences, no CTEs)

-- Customers (include Dev Patel & Hitaxi Lethwala + 8 more)
INSERT INTO customers (name, gender, date_of_birth, phone_number, address, account_type) VALUES
('Dev Patel','M','1999-08-10','+1-617-000-1000','Boston, MA','PREMIUM'),
('Hitaxi Lethwala','F','1998-11-22','+1-617-000-1001','Cambridge, MA','STANDARD'),
('Ava Brown','F','1995-02-14','+1-617-000-1002','Somerville, MA','STANDARD'),
('Liam Johnson','M','1993-06-20','+1-617-000-1003','Brookline, MA','STANDARD'),
('Noah Davis','M','1990-10-03','+1-617-000-1004','Quincy, MA','STANDARD'),
('Emma Wilson','F','1996-12-01','+1-617-000-1005','Medford, MA','PREMIUM'),
('Olivia Miller','F','1997-01-19','+1-617-000-1006','Everett, MA','STANDARD'),
('Mason Anderson','M','1992-03-30','+1-617-000-1007','Chelsea, MA','STANDARD'),
('Sophia Thomas','F','1994-05-25','+1-617-000-1008','Revere, MA','STANDARD'),
('James Moore','M','1991-07-17','+1-617-000-1009','Malden, MA','PREMIUM');

-- Restaurants (4)
INSERT INTO restaurants (name, cuisine_type, location, rating) VALUES
('Spice Route', 'Indian', 'Back Bay', 4.6),
('Pizza Plaza', 'Italian', 'Fenway', 4.3),
('Sushi Sensei', 'Japanese', 'Seaport', 4.7),
('Green Bowl', 'Healthy', 'Downtown', 4.4);

-- Menus (one current menu each)
INSERT INTO menus (restaurant_id, effective_date) VALUES
(1,'2025-11-01'),
(2,'2025-11-01'),
(3,'2025-11-01'),
(4,'2025-11-01');

-- Menu Items (at least 10)
INSERT INTO menu_items (menu_id, name, price, availability) VALUES
(1,'Butter Chicken', 15.99,1),
(1,'Paneer Tikka', 12.49,1),
(1,'Veg Biryani', 11.99,1),
(2,'Margherita Pizza', 10.99,1),
(2,'Pepperoni Pizza', 12.99,1),
(2,'Garlic Bread', 5.49,1),
(3,'California Roll', 9.99,1),
(3,'Salmon Nigiri', 13.49,1),
(4,'Quinoa Salad', 8.99,1),
(4,'Avocado Wrap', 9.49,1);

-- Promotions (2)
INSERT INTO promotions (code, discount_type, value, validity_start, validity_end) VALUES
('WELCOME10','PERCENT',10.00,'2025-11-01','2025-12-31'),
('FLAT5','FLAT',5.00,'2025-11-01','2025-12-31');

-- Orders (10) — mix customers/restaurants, some with promo
INSERT INTO orders (customer_id, restaurant_id, promo_id, order_time, total_amount, status) VALUES
(1,1,1,'2025-11-09 18:10:00',27.98,'DELIVERED'),   -- Dev
(2,2,NULL,'2025-11-09 18:15:00',16.48,'DELIVERED'),-- Hitaxi
(3,3,2,'2025-11-09 18:20:00',22.48,'DELIVERED'),
(4,4,NULL,'2025-11-09 18:25:00',18.98,'DELIVERED'),
(5,1,NULL,'2025-11-09 18:30:00',11.99,'DELIVERED'),
(6,2,1,'2025-11-09 18:35:00',23.98,'DELIVERED'),
(7,3,NULL,'2025-11-09 18:40:00',13.49,'DELIVERED'),
(8,4,NULL,'2025-11-09 18:45:00',8.99,'DELIVERED'),
(9,2,2,'2025-11-09 18:50:00',23.98,'DELIVERED'),
(10,1,NULL,'2025-11-09 18:55:00',24.48,'DELIVERED');

-- Order Items (each order at least one item; store price at time of order)
INSERT INTO order_items (order_id, item_id, quantity, item_price) VALUES
(1,1,1,15.99), (1,2,1,12.49),
(2,4,1,10.99), (2,6,1,5.49),
(3,7,1,9.99),  (3,8,1,13.49),
(4,9,1,8.99),  (4,10,1,9.99),
(5,3,1,11.99),
(6,4,1,10.99), (6,5,1,12.99),
(7,8,1,13.49),
(8,9,1,8.99),
(9,4,1,10.99), (9,5,1,12.99),
(10,2,1,12.49), (10,3,1,11.99);

-- Payments (1 per order)
INSERT INTO payments (order_id, method, transaction_id, amount, status) VALUES
(1,'CARD','TXN10001',27.98,'SUCCESS'),
(2,'CARD','TXN10002',16.48,'SUCCESS'),
(3,'WALLET','TXN10003',22.48,'SUCCESS'),
(4,'CARD','TXN10004',18.98,'SUCCESS'),
(5,'CASH_ON_DELIVERY',NULL,11.99,'SUCCESS'),
(6,'CARD','TXN10006',23.98,'SUCCESS'),
(7,'CARD','TXN10007',13.49,'SUCCESS'),
(8,'WALLET','TXN10008',8.99,'SUCCESS'),
(9,'CARD','TXN10009',23.98,'SUCCESS'),
(10,'CARD','TXN10010',24.48,'SUCCESS');

-- Drivers (4)
INSERT INTO drivers (name, rating, contact, status) VALUES
('Raj Mehta', 4.8, '+1-617-200-0001', 'AVAILABLE'),
('Kim Lee',   4.5, '+1-617-200-0002', 'AVAILABLE'),
('Carlos Ruiz',4.6, '+1-617-200-0003', 'AVAILABLE'),
('Mina Park', 4.7, '+1-617-200-0004', 'AVAILABLE');

-- Vehicles (mapped 1-1 to first three drivers)
INSERT INTO vehicles (driver_id, type, license_plate) VALUES
(1,'SCOOTER','MA-AB12'),
(2,'BIKE','MA-BK34'),
(3,'CAR','MA-CR56'),
(NULL,'BIKE','MA-BK78'); -- spare bike, unassigned

-- Deliveries (1 per order; assign to drivers)
INSERT INTO deliveries (order_id, driver_id, pickup_time, dropoff_time, eta, status) VALUES
(1,1,'2025-11-09 18:12:00','2025-11-09 18:35:00',18,'DELIVERED'),
(2,2,'2025-11-09 18:17:00','2025-11-09 18:37:00',17,'DELIVERED'),
(3,3,'2025-11-09 18:22:00','2025-11-09 18:50:00',20,'DELIVERED'),
(4,4,'2025-11-09 18:27:00','2025-11-09 18:55:00',22,'DELIVERED'),
(5,1,'2025-11-09 18:32:00','2025-11-09 18:55:00',18,'DELIVERED'),
(6,2,'2025-11-09 18:37:00','2025-11-09 19:00:00',18,'DELIVERED'),
(7,3,'2025-11-09 18:42:00','2025-11-09 19:02:00',16,'DELIVERED'),
(8,4,'2025-11-09 18:47:00','2025-11-09 19:05:00',14,'DELIVERED'),
(9,1,'2025-11-09 18:52:00','2025-11-09 19:15:00',20,'DELIVERED'),
(10,2,'2025-11-09 18:57:00','2025-11-09 19:20:00',20,'DELIVERED');

-- Reviews (a few)
INSERT INTO reviews (reviewer_id, target_type, target_id, rating, comment) VALUES
(1,'RESTAURANT',1,4.5,'Great Indian flavors'),
(2,'RESTAURANT',2,4.0,'Crisp crust'),
(3,'DRIVER',1,5.0,'Super fast'),
(4,'DRIVER',2,4.5,'On time');

-- 3) Basic outputs (no analytics) — show 10 rows each
-- Tip: Result grid “bigger” in Workbench = zoom in (Ctrl/Cmd +) or drag panel splitter.

-- 3.1 Customers (includes Dev Patel & Hitaxi Lethwala)
SELECT * FROM customers ORDER BY customer_id LIMIT 10;

-- 3.2 Restaurants
SELECT * FROM restaurants ORDER BY restaurant_id LIMIT 10;

-- 3.3 Menu Items (with restaurant via menu)
SELECT mi.item_id, r.name AS restaurant, mi.name AS item_name, mi.price, mi.availability
FROM menu_items mi
JOIN menus m  ON mi.menu_id = m.menu_id
JOIN restaurants r ON m.restaurant_id = r.restaurant_id
ORDER BY mi.item_id
LIMIT 10;

-- 3.4 Orders joined to Customer & Restaurant (10 rows)
SELECT o.order_id, o.order_time, c.name AS customer, r.name AS restaurant, o.total_amount, o.status
FROM orders o
JOIN customers c  ON o.customer_id = c.customer_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
ORDER BY o.order_id
LIMIT 10;

-- 3.5 Order Items merged with Item Name + Customer + Restaurant (10 rows)
SELECT oi.order_item_id, oi.order_id,
       c.name AS customer, r.name AS restaurant,
       mi.name AS item_name, oi.quantity, oi.item_price
FROM order_items oi
JOIN orders o       ON oi.order_id = o.order_id
JOIN customers c    ON o.customer_id = c.customer_id
JOIN restaurants r  ON o.restaurant_id = r.restaurant_id
JOIN menu_items mi  ON oi.item_id = mi.item_id
ORDER BY oi.order_item_id
LIMIT 10;

-- 3.6 Payments (10)
SELECT payment_id, order_id, method, transaction_id, amount, status
FROM payments
ORDER BY payment_id
LIMIT 10;

-- 3.7 Deliveries (10)
SELECT d.delivery_id, d.order_id, dr.name AS driver, d.status, d.pickup_time, d.dropoff_time, d.eta
FROM deliveries d
JOIN drivers dr ON d.driver_id = dr.driver_id
ORDER BY d.delivery_id
LIMIT 10;

-- 3.8 Promotions (show all)
SELECT * FROM promotions ORDER BY promo_id;
