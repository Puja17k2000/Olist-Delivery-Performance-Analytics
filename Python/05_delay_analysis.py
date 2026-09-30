import sqlite3, os, pandas as pd

base = os.path.dirname(os.path.abspath(__file__))
conn = sqlite3.connect(os.path.join(base, "..", "Dataset", "olist.db"))
sql = open(os.path.join(base, "..", "SQL", "05_delay_analysis.sql"), encoding="utf-8").read()

pd.set_option("display.width", 200)
for q in [s for s in sql.split(";") if s.strip()]:
    print(pd.read_sql(q, conn).to_string(index=False))
    print()