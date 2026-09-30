-- 1. Order status breakdown
SELECT order_status, COUNT(*) AS n
FROM orders
GROUP BY order_status
ORDER BY n DESC;

-- 2. Date range of the data
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM orders;

-- 3. Duplicate order IDs (should be 0)
SELECT COUNT(*) - COUNT(DISTINCT order_id) AS dup_orders FROM orders;

-- 4. Missing dates
SELECT
  SUM(order_delivered_customer_date IS NULL) AS no_delivery_date,
  SUM(order_estimated_delivery_date IS NULL) AS no_estimate
FROM orders;

-- 5. Orders with no items
SELECT COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL;

-- 6. Order-level IDs vs real unique customers
SELECT COUNT(DISTINCT customer_id) AS customer_ids,
       COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;