DROP TABLE IF EXISTS seller_scorecard;

CREATE TABLE seller_scorecard AS
WITH seller_orders AS (
  SELECT seller_id, order_id, SUM(price) AS seller_gmv
  FROM fact_order_items
  GROUP BY seller_id, order_id
),
seller_stats AS (
  SELECT so.seller_id,
         COUNT(*) AS orders,
         ROUND(SUM(so.seller_gmv), 0) AS gmv,
         SUM(f.is_late) AS late_orders,
         ROUND(100.0 * SUM(f.is_late) / COUNT(*), 2) AS late_pct,
         ROUND(AVG(f.review_score), 2) AS avg_review,
         ROUND(AVG(julianday(o.order_delivered_carrier_date) - julianday(o.order_approved_at)), 1) AS handling_days
  FROM seller_orders so
  JOIN fact_orders f ON so.order_id = f.order_id
  JOIN orders o ON so.order_id = o.order_id
  WHERE f.is_delivered = 1
  GROUP BY so.seller_id
  HAVING COUNT(*) >= 30
)
SELECT s.seller_id,
       d.seller_state,
       s.orders, s.gmv, s.late_orders, s.late_pct, s.avg_review, s.handling_days,
       RANK() OVER (ORDER BY s.late_pct DESC) AS late_rank,
       NTILE(10) OVER (ORDER BY s.late_pct DESC) AS late_decile
FROM seller_stats s
JOIN dim_sellers d ON s.seller_id = d.seller_id;

SELECT COUNT(*) AS sellers_in_scorecard,
       SUM(orders) AS seller_orders,
       SUM(late_orders) AS late_orders
FROM seller_scorecard;

SELECT late_decile,
       COUNT(*) AS sellers,
       SUM(orders) AS orders,
       SUM(late_orders) AS late_orders,
       ROUND(100.0 * SUM(late_orders) / SUM(orders), 2) AS late_pct,
       ROUND(100.0 * SUM(late_orders) / (SELECT SUM(late_orders) FROM seller_scorecard), 1) AS share_of_late_orders
FROM seller_scorecard
GROUP BY late_decile
ORDER BY late_decile;

SELECT seller_id, seller_state, orders, late_pct, avg_review, handling_days
FROM seller_scorecard
ORDER BY late_rank
LIMIT 10;