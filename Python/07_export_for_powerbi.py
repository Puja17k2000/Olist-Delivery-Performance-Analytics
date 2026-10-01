import os, sqlite3, pandas as pd

base = os.path.dirname(os.path.abspath(__file__))
conn = sqlite3.connect(os.path.join(base, "..", "Dataset", "olist.db"))
out = os.path.join(base, "..", "Dataset", "PowerBI_Data")
os.makedirs(out, exist_ok=True)

fact = pd.read_sql("""
    SELECT f.order_id, f.customer_unique_id, f.customer_state, f.purchase_month,
           date(f.order_purchase_timestamp) AS purchase_date,
           f.gmv, f.review_score, f.is_delivered, f.delivery_days, f.delay_days, f.is_late,
           CASE WHEN f.delay_days IS NULL THEN NULL
                WHEN f.delay_days <= 0 THEN '1. On time'
                WHEN f.delay_days <= 3 THEN '2. 1-3 days late'
                WHEN f.delay_days <= 7 THEN '3. 4-7 days late'
                WHEN f.delay_days <= 14 THEN '4. 8-14 days late'
                ELSE '5. 15+ days late' END AS delay_bucket
    FROM fact_orders f
    WHERE f.is_delivered = 1
""", conn)
fact.to_csv(os.path.join(out, "fact_orders.csv"), index=False)

pd.read_sql("SELECT * FROM seller_scorecard", conn).to_csv(os.path.join(out, "seller_scorecard.csv"), index=False)

fc = pd.read_csv(os.path.join(base, "..", "Dataset", "Cleaned", "gmv_forecast.csv"))
fc.to_csv(os.path.join(out, "gmv_forecast.csv"), index=False)

print("fact_orders", len(fact))
print("Saved files in", out)