-- 1. Overall KPIs (delivered orders)
SELECT COUNT(*) AS delivered_orders,
       ROUND(100.0 * SUM(1 - is_late) / COUNT(*), 2) AS on_time_pct,
       ROUND(AVG(delivery_days), 1) AS avg_delivery_days,
       ROUND(AVG(CASE WHEN is_late = 1 THEN delay_days END), 1) AS avg_delay_late_orders,
       ROUND(SUM(gmv), 0) AS gmv,
       ROUND(SUM(gmv) / COUNT(*), 2) AS aov
FROM fact_orders
WHERE is_delivered = 1;

-- 2. Late % by customer state (states with 500+ orders)
SELECT customer_state,
       COUNT(*) AS orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct,
       ROUND(AVG(delivery_days), 1) AS avg_delivery_days,
       ROUND(AVG(review_score), 2) AS avg_review
FROM fact_orders
WHERE is_delivered = 1
GROUP BY customer_state
HAVING COUNT(*) >= 500
ORDER BY late_pct DESC;

-- 3. Late % by month (2017-01 to 2018-08)
SELECT purchase_month,
       COUNT(*) AS orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_pct
FROM fact_orders
WHERE is_delivered = 1
  AND purchase_month BETWEEN '2017-01' AND '2018-08'
GROUP BY purchase_month
ORDER BY purchase_month;

-- 4. Review score by how late the order was
SELECT CASE WHEN delay_days <= 0 THEN '1. On time'
            WHEN delay_days <= 3 THEN '2. 1-3 days late'
            WHEN delay_days <= 7 THEN '3. 4-7 days late'
            WHEN delay_days <= 14 THEN '4. 8-14 days late'
            ELSE '5. 15+ days late' END AS delay_bucket,
       COUNT(*) AS orders,
       ROUND(AVG(review_score), 2) AS avg_review
FROM fact_orders
WHERE is_delivered = 1
GROUP BY delay_bucket
ORDER BY delay_bucket;