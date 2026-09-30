# Data Quality Log

| # | Table | Issue | Count | Decision |
|---|---|---|---|---|
| 1 | orders | Duplicate order_id | 0 | No action |
| 2 | orders | Missing delivery date, non-delivered orders | 2,957 | Expected (order not delivered). Excluded from delay analysis |
| 3 | orders | Delivered orders with missing delivery date | 8 | Excluded from delay analysis |
| 4 | orders | Orders with no items | 775 | All non-delivered. No impact on delivered analysis |
| 5 | customers | customer_id is per order, not per person | 99,441 IDs vs 96,096 people | Use customer_unique_id for customer-level metrics |
| 6 | orders | Dates stored as text | 5 date columns | Convert to datetime |
| 7 | orders | No orders in 2016-11; very few in 2016-09/10/12 and 2018-09/10 | 6 months | Forecasting window limited to 2017-01 to 2018-08 |
| 8 | orders | Delivery date before purchase date | 0 | No action |
| 9 | order_reviews | Duplicate reviews for the same order | 551 | Kept the most recent review per order |
| 10 | order_reviews | Delivered orders with no review score | 646 | Kept in delivery analysis, excluded from review analysis |

Analysis base: 96,470 delivered orders with a valid delivery date.