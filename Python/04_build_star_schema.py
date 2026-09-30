import sqlite3, os

base = os.path.dirname(os.path.abspath(__file__))
conn = sqlite3.connect(os.path.join(base, "..", "Dataset", "olist.db"))

with open(os.path.join(base, "..", "SQL", "03_build_star_schema.sql"), encoding="utf-8") as f:
    conn.executescript(f.read())
conn.commit()

for t in ["dim_customers", "dim_sellers", "dim_products", "fact_order_items", "fact_orders"]:
    n = conn.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
    print(t, n)
conn.close()