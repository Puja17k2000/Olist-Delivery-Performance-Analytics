import pandas as pd, sqlite3, glob, os

base = os.path.dirname(os.path.abspath(__file__))
raw = os.path.join(base, "..", "Dataset", "Raw")
db_path = os.path.join(base, "..", "Dataset", "olist.db")

conn = sqlite3.connect(db_path)
for f in sorted(glob.glob(os.path.join(raw, "*.csv"))):
    name = (os.path.basename(f)
            .replace("olist_", "")
            .replace("_dataset.csv", "")
            .replace(".csv", ""))
    df = pd.read_csv(f)
    df.to_sql(name, conn, if_exists="replace", index=False)
    print(f"{name}: {len(df)} rows")
conn.close()