DROP TABLE IF EXISTS dim_customers;
DROP TABLE IF EXISTS dim_sellers;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS fact_order_items;
DROP TABLE IF EXISTS fact_orders;

CREATE TABLE dim_customers AS
SELECT customer_id, customer_unique_id, customer_city, customer_state
FROM customers;

CREATE TABLE dim_sellers AS
SELECT seller_id, seller_city, seller_state
FROM sellers;

CREATE TABLE dim_products AS
SELECT p.product_id,
       COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       p.product_weight_g
FROM products p
LEFT JOIN product_category_name_translation t
       ON p.product_category_name = t.product_category_name;

CREATE TABLE fact_order_items AS
SELECT order_id, order_item_id, product_id, seller_id, price, freight_value
FROM order_items;

CREATE TABLE fact_orders AS
WITH items AS (
  SELECT order_id,
         COUNT(*) AS item_count,
         SUM(price) AS items_value,
         SUM(freight_value) AS freight_value
  FROM order_items
  GROUP BY order_id
),
pay AS (
  SELECT order_id, SUM(payment_value) AS payment_value
  FROM order_payments
  GROUP BY order_id
),
rev AS (
  SELECT order_id, review_score
  FROM (
    SELECT order_id, review_score,
           ROW_NUMBER() OVER (
             PARTITION BY order_id
             ORDER BY review_creation_date DESC, review_answer_timestamp DESC
           ) AS rn
    FROM order_reviews
  )
  WHERE rn = 1
),
base AS (
  SELECT o.order_id,
         o.customer_id,
         c.customer_unique_id,
         c.customer_state,
         o.order_status,
         o.order_purchase_timestamp,
         o.order_delivered_customer_date,
         o.order_estimated_delivery_date,
         strftime('%Y-%m', o.order_purchase_timestamp) AS purchase_month,
         COALESCE(i.item_count, 0) AS item_count,
         COALESCE(i.items_value, 0) AS items_value,
         COALESCE(i.freight_value, 0) AS freight_value,
         COALESCE(i.items_value, 0) + COALESCE(i.freight_value, 0) AS gmv,
         p.payment_value,
         r.review_score,
         CASE WHEN o.order_status = 'delivered'
                   AND o.order_delivered_customer_date IS NOT NULL
              THEN 1 ELSE 0 END AS is_delivered,
         CASE WHEN o.order_status = 'delivered'
                   AND o.order_delivered_customer_date IS NOT NULL
              THEN ROUND(julianday(o.order_delivered_customer_date)
                       - julianday(o.order_purchase_timestamp), 1) END AS delivery_days,
         CASE WHEN o.order_status = 'delivered'
                   AND o.order_delivered_customer_date IS NOT NULL
              THEN CAST(julianday(date(o.order_delivered_customer_date))
                      - julianday(date(o.order_estimated_delivery_date)) AS INTEGER) END AS delay_days
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  LEFT JOIN items i ON o.order_id = i.order_id
  LEFT JOIN pay p ON o.order_id = p.order_id
  LEFT JOIN rev r ON o.order_id = r.order_id
)
SELECT *,
       CASE WHEN delay_days IS NULL THEN NULL
            WHEN delay_days > 0 THEN 1 ELSE 0 END AS is_late
FROM base;