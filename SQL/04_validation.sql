-- 1. Orders, delivered, late
SELECT COUNT(*) AS total_orders,
       SUM(is_delivered) AS delivered_orders,
       SUM(is_late) AS late_orders
FROM fact_orders;

-- 2. Review score: on-time vs late
SELECT is_late,
       COUNT(review_score) AS reviews,
       ROUND(AVG(review_score), 2) AS avg_review
FROM fact_orders
WHERE is_delivered = 1
GROUP BY is_late;