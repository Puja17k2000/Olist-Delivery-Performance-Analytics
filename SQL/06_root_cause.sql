-- 1. Where does the time go? On-time vs late orders (days)
SELECT f.is_late,
       COUNT(*) AS orders,
       ROUND(AVG(julianday(o.order_approved_at) - julianday(o.order_purchase_timestamp)), 1) AS approval_days,
       ROUND(AVG(julianday(o.order_delivered_carrier_date) - julianday(o.order_approved_at)), 1) AS seller_handling_days,
       ROUND(AVG(julianday(o.order_delivered_customer_date) - julianday(o.order_delivered_carrier_date)), 1) AS carrier_transit_days
FROM fact_orders f
JOIN orders o ON f.order_id = o.order_id
WHERE f.is_delivered = 1
GROUP BY f.is_late;

-- 2. Same-state vs different-state delivery
WITH order_seller AS (
  SELECT oi.order_id, MIN(s.seller_state) AS seller_state
  FROM order_items oi
  JOIN sellers s ON oi.seller_id = s.seller_id
  GROUP BY oi.order_id
)
SELECT CASE WHEN os.seller_state = f.customer_state THEN 'Same state' ELSE 'Different state' END AS route,
       COUNT(*) AS orders,
       ROUND(100.0 * SUM(f.is_late) / COUNT(*), 2) AS late_pct,
       ROUND(AVG(f.delivery_days), 1) AS avg_delivery_days
FROM fact_orders f
JOIN order_seller os ON f.order_id = os.order_id
WHERE f.is_delivered = 1
GROUP BY route;