CREATE DATABASE ecommerce_db;
USE ecommerce_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50),
    registration_date DATE
);


CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2),
    FOREIGN KEY (category_id)
    REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    status VARCHAR(30),
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    payment_status VARCHAR(30),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT UNIQUE,
    stock_quantity INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100),
    city VARCHAR(50),
    phone VARCHAR(15)
);

INSERT INTO customers
(name, email, city, registration_date)
VALUES
('Rahul Sharma', 'rahul@gmail.com', 'Mumbai', '2025-01-10'),
('Amit Kumar', 'amit@gmail.com', 'Delhi', '2025-02-15'),
('Priya Singh', 'priya@gmail.com', 'Pune', '2025-03-20'),
('Neha Verma', 'neha@gmail.com', 'Mumbai', '2025-04-05'),
('Vikas Patel', 'vikas@gmail.com', 'Ahmedabad', '2025-05-12');

INSERT INTO categories (category_name)
VALUES
('Electronics'),
('Clothing'),
('Books'),
('Furniture');

INSERT INTO products
(product_name, category_id, price)
VALUES
('Laptop', 1, 55000),
('Mobile', 1, 25000),
('Headphones', 1, 2000),
('T-Shirt', 2, 500),
('SQL Book', 3, 800),
('Office Chair', 4, 4500);

INSERT INTO suppliers (supplier_name, city, phone)
VALUES
('Tech Solutions', 'Mumbai', '9876543210'),
('Global Traders', 'Delhi', '9876543211');

INSERT INTO orders (customer_id, order_date, status)
VALUES
(1, '2025-06-01', 'Delivered'),
(2, '2025-06-02', 'Pending'),
(3, '2025-06-03', 'Delivered'),
(1, '2025-06-05', 'Delivered'),
(4, '2025-06-06', 'Cancelled');

INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 55000),
(1, 3, 2, 2000),
(2, 2, 1, 25000),
(3, 5, 2, 800),
(4, 4, 3, 500);

INSERT INTO payments
(order_id, amount, payment_date, payment_status)
VALUES
(1, 59000, '2025-06-01', 'Success'),
(2, 25000, '2025-06-02', 'Pending'),
(3, 1600, '2025-06-03', 'Success'),
(4, 1500, '2025-06-05', 'Success');

INSERT INTO inventory (product_id, stock_quantity)
VALUES
(1, 10),
(2, 20),
(3, 50),
(4, 100),
(5, 30),
(6, 15);



-- Find all customers from Mumbai
SELECT *
FROM customers
WHERE city = 'Mumbai';

-- Find products costing more than 1000
SELECT *
FROM products
WHERE price > 1000;

-- Find products in descending price order
SELECT *
FROM products
ORDER BY price DESC;

-- Find customers whose name starts with A
SELECT *
FROM customers
WHERE name LIKE 'A%';



-- Total number of customers
SELECT COUNT(*) FROM customers;

-- Average product price
SELECT AVG(price) FROM products;

-- Highest product price
SELECT MAX(price) FROM products;

-- Number of customers in each city
SELECT city, COUNT(*) AS total_customers
FROM customers
GROUP BY city;

-- Cities having more than one customer
SELECT city, COUNT(*) AS total
FROM customers
GROUP BY city
HAVING COUNT(*) > 1;


-- Display customer names with order IDs
SELECT
    c.name,
    o.order_id,
    o.order_date
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id;

-- Find customers who never placed an order
SELECT c.*
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Display products with their category names
SELECT
    p.product_name,
    c.category_name
FROM products p
INNER JOIN categories c
ON p.category_id = c.category_id;


-- Products costing more than average price
SELECT *
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
);

-- Customers who have placed orders
SELECT *
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
);



-- Rank products by price
SELECT
    product_name,
    price,
    RANK() OVER (
        ORDER BY price DESC
    ) AS product_rank
FROM products;

-- Find the second-highest product price
WITH ranked_products AS (
    SELECT
        product_name,
        price,
        DENSE_RANK() OVER (
            ORDER BY price DESC
        ) AS rnk
    FROM products
)
SELECT *
FROM ranked_products
WHERE rnk = 2;


-- Categorize products by price
SELECT
    product_name,
    price,
    CASE
        WHEN price >= 50000 THEN 'Expensive'
        WHEN price >= 5000 THEN 'Medium'
        ELSE 'Affordable'
    END AS price_category
FROM products;



SELECT
    p.product_name,
    SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY total_sold DESC
LIMIT 5;

SELECT SUM(amount) AS total_revenue
FROM payments
WHERE payment_status = 'Success';



SELECT
    c.customer_id,
    c.name,
    SUM(p.amount) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
WHERE p.payment_status = 'Success'
GROUP BY c.customer_id, c.name
HAVING SUM(p.amount) > 10000;




SELECT
    YEAR(payment_date) AS year,
    MONTH(payment_date) AS month,
    SUM(amount) AS monthly_revenue
FROM payments
WHERE payment_status = 'Success'
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY year, month;alter




SELECT
    p.product_name,
    i.stock_quantity
FROM products p
JOIN inventory i
    ON p.product_id = i.product_id
WHERE i.stock_quantity < 10;




SELECT
    c.name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) > 1;



CREATE VIEW customer_order_report AS
SELECT
    c.name,
    o.order_id,
    o.order_date,
    o.status
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;




SELECT * FROM customer_order_report;

DELIMITER //

CREATE PROCEDURE GetCustomerOrders(
    IN input_customer_id INT
)
BEGIN
    SELECT *
    FROM orders
    WHERE customer_id = input_customer_id;
END //

DELIMITER ;


CALL GetCustomerOrders(1);

DELIMITER //

CREATE TRIGGER reduce_stock
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET stock_quantity =
        stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END //

DELIMITER ;


START TRANSACTION;

UPDATE inventory
SET stock_quantity = stock_quantity - 2
WHERE product_id = 1
AND stock_quantity >= 2;

-- Check whether the update affected a row
-- before committing.

COMMIT;


ROLLBACK;


CREATE INDEX idx_customer_city
ON customers(city);

CREATE INDEX idx_order_date
ON orders(order_date);

CREATE INDEX idx_product_price
ON products(price);



EXPLAIN
SELECT *
FROM customers
WHERE city = 'Mumbai';













