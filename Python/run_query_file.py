import sqlite3, sys, pandas as pd

conn = sqlite3.connect("Dataset/olist.db")
sql = open(sys.argv[1], encoding="utf-8").read()

pd.set_option("display.width", 200)
for q in [s for s in sql.split(";") if s.strip()]:
    print(pd.read_sql(q, conn).to_string(index=False))
    print()