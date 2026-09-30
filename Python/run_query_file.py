import sqlite3, sys, pandas as pd

conn = sqlite3.connect("Dataset/olist.db")
sql = open(sys.argv[1], encoding="utf-8").read()

pd.set_option("display.width", 200)
for q in [s for s in sql.split(";") if s.strip()]:
    cur = conn.execute(q)
    if cur.description:
        cols = [d[0] for d in cur.description]
        print(pd.DataFrame(cur.fetchall(), columns=cols).to_string(index=False))
        print()
conn.commit()