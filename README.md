# 📦 Supply Chain Analytics

> **End-to-end SQL analytics system for supply chain operations** — tracking supplier performance, demand forecasting, stockout risk, and inventory health. Built from **27+ months of hands-on stock management experience** at The Range.

[![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)](https://www.postgresql.org/) [![Status](https://img.shields.io/badge/Status-Active-brightgreen)](https://github.com/manojkumarkavuri20-a11y/supply-chain-analytics) [![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

## 👀 Quick Start for Recruiters

| If you want to see... | SQL Module |
|---|---|
| Supplier reliability & late delivery analysis | [`sql/lead_time_analysis.sql`](sql/lead_time_analysis.sql) |
| Supplier risk scoring & scorecard | [`sql/supplier_performance.sql`](sql/supplier_performance.sql) |
| Demand forecasting & reorder points | [`sql/demand_forecasting.sql`](sql/demand_forecasting.sql) |
| Stockout risk dashboard & ABC classification | [`sql/stockout_risk.sql`](sql/stockout_risk.sql) |

**Sample output from `stockout_risk.sql`:**

| sku | product_name | days_of_stock | lead_time_days | risk_flag | abc_class |
|---|---|---|---|---|---|
| SKU-001 | AA Batteries 4pk | 3 | 7 | CRITICAL | A |
| SKU-047 | USB-C Cable 2m | 6 | 7 | WARNING | A |
| SKU-112 | Picture Frame 8x10 | 94 | 14 | OVERSTOCK | C |
| SKU-203 | Extension Lead 4m | 12 | 7 | WATCH | B |

## 🎯 Business Problem

Retail and operations teams face critical supply chain blind spots:

- **Late deliveries** disrupt shop-floor availability and customer satisfaction
- **Long supplier lead times** increase working capital requirements
- **Demand spikes go undetected** until stock runs out
- **No early-warning system** for potential stockouts before they happen
- **Overstock ties up capital** in slow-moving SKUs

This project builds a **structured SQL analytics layer** to surface these issues proactively, enabling data-driven procurement and replenishment decisions.

## 🗂️ Repository Structure

```
supply-chain-analytics/
├── sql/
│   ├── lead_time_analysis.sql      # Supplier lead time benchmarking
│   ├── supplier_performance.sql    # Scorecard, risk tiers, cost variance
│   ├── demand_forecasting.sql      # Moving averages, seasonality, ROP, EOQ
│   └── stockout_risk.sql           # Risk assessment, ABC classification, overstock
├── data/
│   ├── sample_data.csv
│   └── data_dictionary.md
├── docs/
│   ├── findings_report.md
│   └── kpi_definitions.md
└── README.md
```

## 📊 SQL Modules Overview

### 1. `lead_time_analysis.sql` — Supplier Lead Time Benchmarking

Analyses actual vs promised delivery windows across all suppliers.

Key queries include lead time distribution and percentile analysis (P50, P75, P95), supplier reliability ranking by on-time delivery rate, late delivery root cause breakdown by category/region, and lead time trend over rolling 6-month window.

### 2. `supplier_performance.sql` — Supplier Scorecard & Risk

Comprehensive supplier evaluation using a weighted composite score.

- **Composite Scorecard**: 40% On-Time Delivery + 30% Fill Rate + 30% Quality
- **Risk Tier Classification**: Preferred / Approved / Conditional / At Risk
- **MoM Trend**: Tracks if supplier performance is improving or declining
- **Cost Variance Analysis**: Flags suppliers billing above contracted price

### 3. `demand_forecasting.sql` — Demand Planning & Replenishment

Forecasting and inventory planning using statistical methods in SQL.

- 4-week & 12-week Moving Averages with rolling window functions
- Seasonality Index: Monthly demand vs annual average (Peak / Low / Normal)
- Reorder Point (ROP): `(Avg Daily Demand × Lead Time) + Safety Stock`
- Safety Stock: `Z(1.645) × StdDev(demand) × √Lead Time` at 95% service level
- Economic Order Quantity (EOQ): `√(2DS/H)` formula
- Demand Variance Alert: Flags >30% deviation from forecast

### 4. `stockout_risk.sql` — Risk Assessment & Inventory Health

Real-time stockout prevention and inventory optimisation.

- **Stockout Risk Dashboard**: Days-of-stock vs lead time with urgency flags (STOCKOUT NOW / CRITICAL / WARNING / WATCH / OK)
- **ABC Classification**: Pareto-based SKU segmentation by revenue contribution
- **Stockout History**: Chronic offenders with estimated lost revenue (GBP)
- **Overstock Identification**: Excess units beyond 90-day supply

## 📊 Key Metrics Tracked

| Metric | Formula | Business Use |
|---|---|---|
| On-Time Delivery % | Deliveries on time / Total | Supplier reliability |
| Fill Rate % | Qty received / Qty ordered | Order completeness |
| Defect Rate % | Defective units / Units received | Quality control |
| Days of Stock | Stock on hand / Avg daily demand | Stockout risk |
| Safety Stock | Z × σ(demand) × √Lead time | Buffer against variability |
| Reorder Point | (Avg demand × Lead time) + Safety stock | Replenishment trigger |
| EOQ | √(2DS/H) | Optimal order quantity |
| ABC Class | Cumulative revenue share | Inventory prioritisation |

## 💡 Key Findings

Based on patterns from hands-on retail operations:

1. **Top 20% of suppliers** account for 80%+ of late deliveries — targeted escalation delivers outsized improvement
2. **December–January seasonality** creates 35–45% demand spike in key categories, requiring 6-week advance buffer
3. **Safety stock at 95% service level** typically requires 15–20% more buffer than simple lead-time-based calculations
4. **A-class SKUs** (top 80% revenue) represent only ~20% of unique products — critical to prioritise replenishment
5. **Overstock identification** consistently finds 8–12% of SKUs with >90 days cover, tying up significant working capital

## 🏆 Business Impact

| Problem | SQL Solution | Outcome |
|---|---|---|
| Reactive stockouts | Stockout risk dashboard with lead time buffer | Early warning 2–3 weeks ahead |
| Supplier blind spots | Composite scorecard + risk tiers | Identified At Risk suppliers for renegotiation |
| Demand guesswork | Moving average + seasonality index | Structured forecasting with variance alerts |
| Overstock costs | 90-day supply excess calculation | Quantified excess stock value for liquidation planning |

## 🛠️ Tools & Technologies

- **PostgreSQL / MySQL** — all queries written and tested
- **Window Functions** — LAG, LEAD, ROWS BETWEEN, PARTITION BY
- **CTEs** — complex multi-step analytical logic
- **Statistical Functions** — STDDEV, SQRT for safety stock and EOQ
- **Power BI** — dashboard visualisation of KPI outputs

## 🔗 Related Projects

- [Retail Operations Intelligence](https://github.com/manojkumarkavuri20-a11y/retail-operations-intelligence) — Inventory accuracy and shrinkage detection
- [UK Retail Footfall Analysis](https://github.com/manojkumarkavuri20-a11y/uk-retail-footfall-analysis) — 109 months of ONS retail data
- [Power BI Marketing KPI Dashboard](https://github.com/manojkumarkavuri20-a11y/powerbi-marketing-kpi-dashboard) — Campaign analytics
- [SQL Portfolio](https://github.com/manojkumarkavuri20-a11y/sql-portfolio) — Business analytics SQL collection

## 👤 About

Built by **Manoj Kumar Kavuri** — Graduate Market & Operations Analyst

📍 Bracknell, UK | 27+ months retail operations at The Range | MSc International Business (Distinction)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/manojkumarkavuri/) [![GitHub](https://img.shields.io/badge/GitHub-Portfolio-181717?style=flat-square&logo=github)](https://github.com/manojkumarkavuri20-a11y)

> Open to Operations Analyst, Business Analyst, and Supply Chain Analyst roles across the UK.


## Getting Started

To run these queries locally you'll need PostgreSQL 13+ installed.

```bash
# Create the database
psql -U postgres -c "CREATE DATABASE supply_chain_analytics;"

# Import sample data
psql -U postgres -d supply_chain_analytics -f data/sample_data.csv

# Run your first query
psql -U postgres -d supply_chain_analytics -f sql/stockout_risk.sql
```

The `data/` folder contains `sample_data.csv` and `data_dictionary.md` with full schema documentation. Start with `stockout_risk.sql` to see the risk dashboard, then work backwards through the other modules.
