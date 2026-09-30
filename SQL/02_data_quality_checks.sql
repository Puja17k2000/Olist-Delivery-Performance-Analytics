-- A. Missing delivery date by order status
SELECT order_status,
       COUNT(*) AS total,
       SUM(order_delivered_customer_date IS NULL) AS no_delivery_date
FROM orders
GROUP BY order_status
ORDER BY total DESC;

-- B. Orders without items, by status
SELECT o.order_status, COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL
GROUP BY o.order_status
ORDER BY orders_without_items DESC;

-- C. Orders per month
SELECT strftime('%Y-%m', order_purchase_timestamp) AS month,
       COUNT(*) AS orders
FROM orders
GROUP BY month
ORDER BY month;

-- D. Customers with 2 or more orders
SELECT COUNT(*) AS repeat_customers
FROM (
  SELECT c.customer_unique_id
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  GROUP BY c.customer_unique_id
  HAVING COUNT(*) > 1
);

-- E. Delivered orders where delivery date is before purchase date
SELECT COUNT(*) AS impossible_dates
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;