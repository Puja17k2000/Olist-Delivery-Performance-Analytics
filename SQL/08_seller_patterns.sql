SELECT late_decile,
       COUNT(*) AS sellers,
       ROUND(AVG(handling_days), 1) AS avg_handling_days,
       ROUND(AVG(avg_review), 2) AS avg_review
FROM seller_scorecard
GROUP BY late_decile
ORDER BY late_decile;

SELECT seller_state,
       COUNT(*) AS sellers,
       SUM(orders) AS orders,
       ROUND(100.0 * SUM(late_orders) / SUM(orders), 2) AS late_pct
FROM seller_scorecard
GROUP BY seller_state
HAVING COUNT(*) >= 10
ORDER BY late_pct DESC;

SELECT CASE WHEN late_decile <= 2 THEN 'Worst 20% sellers' ELSE 'Other 80% sellers' END AS grp,
       COUNT(*) AS sellers,
       SUM(orders) AS orders,
       ROUND(100.0 * SUM(gmv) / (SELECT SUM(gmv) FROM seller_scorecard), 1) AS share_of_gmv,
       ROUND(100.0 * SUM(late_orders) / SUM(orders), 2) AS late_pct
FROM seller_scorecard
GROUP BY grp;