import os, sqlite3
import numpy as np, pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from statsmodels.tsa.holtwinters import ExponentialSmoothing

base = os.path.dirname(os.path.abspath(__file__))
conn = sqlite3.connect(os.path.join(base, "..", "Dataset", "olist.db"))

monthly = pd.read_sql("""
    SELECT purchase_month, ROUND(SUM(gmv), 0) AS gmv, COUNT(*) AS orders
    FROM fact_orders
    WHERE is_delivered = 1
      AND purchase_month BETWEEN '2017-01' AND '2018-08'
    GROUP BY purchase_month
    ORDER BY purchase_month
""", conn)
monthly["month"] = pd.to_datetime(monthly["purchase_month"] + "-01")
monthly = monthly.set_index("month").asfreq("MS")
print(monthly[["gmv", "orders"]])
print()

y = monthly["gmv"]
train, test = y.iloc[:-4], y.iloc[-4:]

def mape(actual, pred):
    return float(np.mean(np.abs((actual.values - np.asarray(pred)) / actual.values)) * 100)

preds = {}
preds["Naive (last value)"] = [train.iloc[-1]] * 4
preds["3-month average"] = [train.iloc[-3:].mean()] * 4

slope, intercept = np.polyfit(np.arange(len(train)), train.values, 1)
preds["Linear trend"] = intercept + slope * np.arange(len(train), len(train) + 4)

hw = ExponentialSmoothing(train, trend="add", damped_trend=True).fit()
preds["Holt damped trend"] = hw.forecast(4).values

results = pd.DataFrame({k: mape(test, v) for k, v in preds.items()}, index=["MAPE %"]).T.round(1)
print(results.sort_values("MAPE %"))

os.makedirs(os.path.join(base, "..", "Images"), exist_ok=True)
monthly["gmv"].plot(marker="o", figsize=(10, 4), title="Monthly GMV (delivered orders)")
plt.ylabel("GMV (R$)")
plt.tight_layout()
plt.savefig(os.path.join(base, "..", "Images", "monthly_gmv.png"), dpi=150)

# ---- Final forecast (best holdout model: 3-month average) ----
pred3 = preds["3-month average"]
err = np.abs(test.values - np.asarray(pred3)) / test.values
band = err.max()

level = y.iloc[-3:].mean()
future = pd.date_range("2018-09-01", periods=3, freq="MS")
fc = pd.DataFrame({"forecast": [level] * 3,
                   "low": [level * (1 - band)] * 3,
                   "high": [level * (1 + band)] * 3}, index=future).round(0)
print()
print("Forecast band = +/-", round(band * 100, 1), "%")
print(fc)

out = pd.concat([y.rename("actual"), fc], axis=1)
out.index.name = "month"
out.to_csv(os.path.join(base, "..", "Dataset", "Cleaned", "gmv_forecast.csv"))

plt.figure(figsize=(10, 4))
plt.plot(y.index, y.values, marker="o", label="Actual")
plt.plot(fc.index, fc["forecast"], marker="o", linestyle="--", label="Forecast")
plt.fill_between(fc.index, fc["low"], fc["high"], alpha=0.2)
plt.title("Monthly GMV: actual and 3-month forecast")
plt.ylabel("GMV (R$)")
plt.legend()
plt.tight_layout()
plt.savefig(os.path.join(base, "..", "Images", "gmv_forecast.png"), dpi=150)