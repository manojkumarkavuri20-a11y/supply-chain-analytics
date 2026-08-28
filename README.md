# Supply Chain Analytics

**Portfolio project built for learning purposes using a synthetic dataset. No employer, client or customer data is used.**

**End-to-end SQL analytics system for supply chain operations** — tracking supplier performance, demand forecasting, stockout risk, and inventory health. Built with a synthetic dataset, modelled on supply chain concepts relevant to 27+ months of hands-on stock management experience at The Range.

[![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)](https://www.postgresql.org/) [![Status](https://img.shields.io/badge/Status-Active-brightgreen)](https://github.com/manojkumarkavuri20-a11y/supply-chain-analytics) [![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

## Quick Start for Recruiters

| If you want to see... | SQL Module |
|---|---|
| Supplier reliability & late delivery analysis | [`sql/lead_time_analysis.sql`](sql/lead_time_analysis.sql) |
| Supplier risk scoring & scorecard | [`sql/supplier_performance.sql`](sql/supplier_performance.sql) |
| Demand forecasting & reorder points | [`sql/demand_forecasting.sql`](sql/demand_forecasting.sql) |
| Stockout risk dashboard & ABC classification | [`sql/stockout_risk.sql`](sql/stockout_risk.sql) |
| Table schema these queries assume | [`data/data_dictionary.md`](data/data_dictionary.md) |

**Illustrative sample output from `stockout_risk.sql` (synthetic data):**

| sku | product_name | days_of_stock | lead_time_days | risk_flag | abc_class |
|---|---|---|---|---|---|
| SKU-001 | AA Batteries 4pk | 3 | 7 | CRITICAL | A |
| SKU-047 | USB-C Cable 2m | 6 | 7 | WARNING | A |
| SKU-112 | Picture Frame 8x10 | 94 | 14 | OVERSTOCK | C |
| SKU-203 | Extension Lead 4m | 12 | 7 | WATCH | B |

## Business Problem

Retail and operations teams face a recurring set of supply chain blind spots: late deliveries that disrupt shop-floor availability and customer satisfaction, long supplier lead times that increase working capital requirements, demand spikes that go undetected until stock actually runs out, no early-warning system for a stockout before it happens, and overstock that ties up capital in slow-moving SKUs. This project builds a structured SQL analytics layer to surface these issues proactively, enabling more data-driven procurement and replenishment decisions.

## Repository Structure

```
supply-chain-analytics/
├── sql/
│ ├── lead_time_analysis.sql # Supplier lead time benchmarking
│ ├── supplier_performance.sql # Scorecard, risk tiers, cost variance
│ ├── demand_forecasting.sql # Moving averages, seasonality, ROP, EOQ
│ └── stockout_risk.sql # Risk assessment, ABC classification, overstock
├── data/
│ └── data_dictionary.md # Table schema the queries assume
└── README.md
```

## SQL Modules Overview

### 1. `lead_time_analysis.sql` — Supplier Lead Time Benchmarking

Analyses actual vs promised delivery windows across all suppliers: lead time distribution and percentile analysis (P50, P75, P95), supplier reliability ranking by on-time delivery rate, late delivery root cause breakdown by category and region, and a lead time trend over a rolling 6-month window.

### 2. `supplier_performance.sql` — Supplier Scorecard & Risk

Comprehensive supplier evaluation using a weighted composite score: 40% on-time delivery, 30% fill rate, and 30% quality. Suppliers are classified into risk tiers (Preferred / Approved / Conditional / At Risk), tracked month over month to see whether performance is improving or declining, and checked against contract prices to flag anyone billing above the agreed rate.

### 3. `demand_forecasting.sql` — Demand Planning & Replenishment

Forecasting and inventory planning using statistical methods in plain SQL: 4-week and 12-week moving averages with rolling window functions, a seasonality index comparing monthly demand against the annual average (Peak / Low / Normal), a reorder point calculated as `(Avg Daily Demand × Lead Time) + Safety Stock`, safety stock via `Z(1.645) × StdDev(demand) × √Lead Time` at a 95% service level, an economic order quantity using the standard `√(2DS/H)` formula, and a demand variance alert that flags any product deviating more than 30% from its forecast.

### 4. `stockout_risk.sql` — Risk Assessment & Inventory Health

Real-time stockout prevention and inventory optimisation: a stockout risk dashboard comparing days-of-stock against lead time with urgency flags (STOCKOUT NOW / CRITICAL / WARNING / WATCH / OK), a Pareto-based ABC classification of SKUs by revenue contribution, a stockout history view surfacing chronic offenders with estimated lost revenue in GBP, and an overstock identification query for excess units beyond a 90-day supply.

## Key Metrics Tracked

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

## Illustrative Findings from Synthetic Data

These are illustrative patterns the queries are designed to surface, generated from the synthetic dataset and informed by general retail supply chain concepts — not measured results from a real employer's data. The top 20% of suppliers can account for the large majority of late deliveries, so targeted escalation with just a handful of accounts can deliver outsized improvement. A December–January seasonality spike shows up clearly in key categories, which argues for building in an advance buffer rather than reacting after the fact. Safety stock calculated at a 95% service level typically comes out higher than a simple lead-time-only estimate would suggest. A-class SKUs, the top revenue share, tend to be a small minority of the unique product count, which is exactly why they need to be prioritised first for replenishment. And the overstock query usually turns up a meaningful share of SKUs sitting on excess cover, which is capital that could be freed up.

## Illustrative Business Impact

This table shows the kind of before/after comparison the queries are designed to support, based on the synthetic dataset — not real, measured results from an employer.

| Problem | SQL Solution | Illustrative Outcome |
|---|---|---|
| Reactive stockouts | Stockout risk dashboard with lead time buffer | Early warning ahead of stockout |
| Supplier blind spots | Composite scorecard + risk tiers | Identifies At Risk suppliers for renegotiation |
| Demand guesswork | Moving average + seasonality index | Structured forecasting with variance alerts |
| Overstock costs | 90-day supply excess calculation | Quantifies excess stock value for liquidation planning |

## Tools & Technologies

All queries are written and tested against PostgreSQL (and are largely MySQL-compatible), leaning on window functions (`LAG`, `LEAD`, `ROWS BETWEEN`, `PARTITION BY`) and CTEs for the multi-step analytical logic, plus `STDDEV` and `SQRT` for the safety stock and EOQ formulas. Power BI is the intended layer for turning the query outputs into an actual dashboard.

## Related Projects

[Retail Operations Intelligence](https://github.com/manojkumarkavuri20-a11y/retail-operations-intelligence) covers inventory accuracy and shrinkage detection, [UK Retail Sales & Category Performance Analysis](https://github.com/manojkumarkavuri20-a11y/uk-retail-footfall-analysis) works through 109 months of ONS retail data, [Power BI Marketing KPI Dashboard](https://github.com/manojkumarkavuri20-a11y/powerbi-marketing-kpi-dashboard) is a campaign analytics build, and [SQL Portfolio](https://github.com/manojkumarkavuri20-a11y/sql-portfolio) is the broader business analytics SQL collection this project sits alongside.

## About

Built by **Manoj Kumar Kavuri** — Graduate Market & Operations Analyst

Bracknell, UK | Background: 27+ months retail operations at The Range | MSc International Business (Distinction)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/manojkumarkavuri/) [![GitHub](https://img.shields.io/badge/GitHub-Portfolio-181717?style=flat-square&logo=github)](https://github.com/manojkumarkavuri20-a11y)

**Open to Operations Analyst, Business Analyst, and Supply Chain Analyst roles across the UK.**

## Getting Started

This repo ships as query logic against a documented schema, not a bundled dataset — [`data/data_dictionary.md`](data/data_dictionary.md) lists every table and column the queries in `sql/` expect (`products`, `suppliers`, `purchase_orders`, `sales`, `inventory`, `stockout_events`, `supplier_contracts`).

To run these queries yourself, install PostgreSQL 13+, create the tables described in `data/data_dictionary.md`, load your own sample rows (or generate synthetic ones matching the schema), then run any query directly, for example:

```bash
psql -U postgres -d supply_chain_analytics -f sql/stockout_risk.sql
```

Start with `stockout_risk.sql` to see the risk dashboard, then work backwards through the other modules.
