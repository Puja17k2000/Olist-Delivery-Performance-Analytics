# Stage 7 Findings: Revenue Forecast

Data: monthly GMV of delivered orders, 2017-01 to 2018-08 (20 months). Holdout test on the last 4 months.

| Model | MAPE |
|---|---|
| 3-month average | 6.1% |
| Naive (last value) | 9.4% |
| Holt damped trend | 26.7% |
| Linear trend | 30.8% |

- Revenue grew fast through 2017 and flattened in 2018 (about R$ 1.0M to 1.13M per month), so trend models over-forecast.
- Chosen model: 3-month average (flat level). Forecast for Sep-Nov 2018: about R$ 1.008M per month, range R$ 0.92M to R$ 1.10M (based on the largest holdout error, +/-8.9%).
- Limits: only 20 months, one Black Friday, 4-month holdout. No seasonality is modelled. Nov 2017 was about 1.5x Oct 2017 (R$ 1.15M), which is above this range, so Nov 2018 needs extra planning that this model cannot size.