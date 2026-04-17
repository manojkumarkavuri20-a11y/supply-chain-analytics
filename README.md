# 📦 Supply Chain Analytics

> **End-to-end SQL analytics system for supply chain operations** — tracking supplier performance, demand forecasting, stockout risk, and inventory health. Built from **27+ months of hands-on stock management experience** at The Range.

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 🎯 Business Problem

Retail and operations teams face critical supply chain blind spots:
- **Late deliveries** disrupt shop-floor availability and customer satisfaction
- **Long supplier lead times** increase working capital requirements
- **Demand spikes go undetected** until stock runs out
- **No early-warning system** for potential stockouts before they happen
- **Overstock ties up capital** in slow-moving SKUs

This project delivers a **structured SQL analytics layer** to surface these issues proactively, enabling data-driven procurement and replenishment decisions.

---

## 🗂️ Repository Structure

```
supply-chain-analytics/
│
├── sql/
│   ├── lead_time_analysis.sql          # Supplier lead time benchmarking
│   ├── supplier_performance.sql        # Scorecard, risk tiers, cost variance
│   ├── demand_forecasting.sql          # Moving averages, seasonality, ROP, EOQ
│   └── stockout_risk.sql               # Risk assessment, ABC classification, overstock
│
├── data/
│   ├── sample_data.csv                 # Anonymised sample dataset
│   └── data_dictionary.md              # Schema and field definitions
│
├── docs/
│   ├── findings_report.md              # Key insights and recommendations
│   └── kpi_definitions.md              # Formula reference guide
│
└── README.md
```

---

## 📊 SQL Modules Overview

### 1. `lead_time_analysis.sql` — Supplier Lead Time Benchmarking
Analyses actual vs promised delivery windows across all suppliers.

**Key queries:**
- Lead time distribution and percentile analysis (P50, P75, P95)
- Supplier reliability ranking by on-time delivery rate
- Late delivery root cause breakdown by category/region
- Lead time trend over rolling 6-month window

---

### 2. `supplier_performance.sql` — Supplier Scorecard & Risk
Comprehensive supplier evaluation using a weighted composite score.

**Key queries:**
- **Composite Scorecard**: 40% On-Time Delivery + 30% Fill Rate + 30% Quality
- **Risk Tier Classification**: Preferred / Approved / Conditional / At Risk
- **MoM Trend**: Tracks if supplier performance is improving or declining
- **Cost Variance Analysis**: Flags suppliers billing above contracted price

```sql
-- Composite Supplier Score Example
ROUND(
    (on_time_pct * 0.40)
    + (fill_rate_pct * 0.30)
    + ((1 - defect_rate) * 100 * 0.30), 1
) AS composite_score
```

---

### 3. `demand_forecasting.sql` — Demand Planning & Replenishment
Forecasting and inventory planning using statistical methods.

**Key queries:**
- **4-week & 12-week Moving Averages** with rolling window functions
- **Seasonality Index**: Monthly demand vs annual average (Peak / Low / Normal flags)
- **Reorder Point (ROP)**: `(Avg Daily Demand × Lead Time) + Safety Stock`
- **Safety Stock**: `Z(1.645) × StdDev(demand) × √Lead Time` (95% service level)
- **Economic Order Quantity (EOQ)**: `√(2DS/H)` formula
- **Demand Variance Alert**: Flags >30% deviation from forecast

---

### 4. `stockout_risk.sql` — Risk Assessment & Inventory Health
Real-time stockout prevention and inventory optimisation.

**Key queries:**
- **Stockout Risk Dashboard**: Days-of-stock vs lead time with urgency flags
  - `STOCKOUT NOW` / `CRITICAL` / `WARNING` / `WATCH` / `OK`
- **ABC Classification**: Pareto-based SKU segmentation by revenue contribution
  - A = top 80% revenue | B = next 15% | C = bottom 5%
- **Stockout History**: Chronic offenders with estimated lost revenue (GBP)
- **Overstock Identification**: Excess units beyond 90-day supply + working capital tied up

---

## 📊 Key Metrics Tracked

| Metric | Formula | Business Use |
|--------|---------|-------------|
| **On-Time Delivery %** | Deliveries on time / Total deliveries | Supplier reliability |
| **Fill Rate %** | Qty received / Qty ordered | Order completeness |
| **Defect Rate %** | Defective units / Units received | Quality control |
| **Days of Stock** | Stock on hand / Avg daily demand | Stockout risk |
| **Safety Stock** | Z × σ(demand) × √Lead time | Buffer against variability |
| **Reorder Point** | (Avg demand × Lead time) + Safety stock | Trigger for replenishment |
| **EOQ** | √(2DS/H) | Optimal order quantity |
| **Seasonality Index** | Monthly demand / Annual monthly avg | Demand pattern detection |
| **ABC Class** | Cumulative revenue share | Inventory prioritisation |
| **Composite Supplier Score** | Weighted: OTD + Fill + Quality | Procurement decisions |

---

## 💡 Key Findings

Based on patterns observed from hands-on retail operations:

1. **Top 20% of suppliers** account for 80%+ of late deliveries — targeted escalation delivers outsized improvement
2. **December–January seasonality** creates 35–45% demand spike in key categories requiring 6-week advance buffer
3. **Safety stock at 95% service level** typically requires 15–20% more buffer than simple lead-time-based calculations
4. **A-class SKUs** (top 80% revenue) represent only ~20% of unique products — critical to prioritise replenishment
5. **Overstock identification** consistently finds 8–12% of SKUs with >90 days cover, tying up significant working capital

---

## 🏆 Business Impact

| Problem | SQL Solution | Outcome |
|---------|-------------|----------|
| Reactive stockouts | Stockout risk dashboard with lead time buffer | Early warning 2–3 weeks ahead |
| Supplier blind spots | Composite scorecard + risk tiers | Identified At Risk suppliers for renegotiation |
| Demand guesswork | Moving average + seasonality index | Structured forecasting with variance alerts |
| Overstock costs | 90-day supply excess calculation | Quantified excess stock value for liquidation planning |
| Contract price creep | Cost variance analysis | Flagged overcharges vs agreed contract price |

---

## 🛠️ Tools & Technologies

- **PostgreSQL / MySQL** — all queries written and tested
- **Window Functions** — LAG, LEAD, ROWS BETWEEN, PARTITION BY
- **CTEs** — complex multi-step analytical logic
- **CASE WHEN** — classification and flagging logic
- **Statistical Functions** — STDDEV, SQRT for safety stock and EOQ
- **Microsoft Excel** — data preparation and validation
- **Power BI** — dashboard visualisation of KPI outputs

---

## 🔗 Related Projects

- [Retail Operations Intelligence](https://github.com/manojkumarkavuri20-a11y/retail-operations-intelligence) — Inventory accuracy and shrinkage detection
- [UK Retail Footfall Analysis](https://github.com/manojkumarkavuri20-a11y/uk-retail-footfall-analysis) — 109 months of ONS retail data
- [Power BI Marketing KPI Dashboard](https://github.com/manojkumarkavuri20-a11y/powerbi-marketing-kpi-dashboard) — Campaign analytics
- [SQL Portfolio](https://github.com/manojkumarkavuri20-a11y/sql-portfolio) — Business analytics SQL collection

---

## 👤 About

Built by **Manoj Kumar Kavuri** — Graduate Market & Operations Analyst

📍 Bracknell, UK | 27+ months retail operations at The Range | MSc International Business (Distinction)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/manojkumarkavuri/)
[![GitHub](https://img.shields.io/badge/GitHub-Portfolio-black?style=flat&logo=github)](https://github.com/manojkumarkavuri20-a11y)

> *Open to Operations Analyst, Business Analyst, and Supply Chain Analyst roles across the UK.*
