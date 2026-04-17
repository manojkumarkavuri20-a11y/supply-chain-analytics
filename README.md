# 📦 Supply Chain Analytics

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue) ![Status](https://img.shields.io/badge/Status-Active-brightgreen) ![License](https://img.shields.io/badge/License-MIT-yellow)

SQL-based supply chain analytics project tracking **supplier lead times**, **delivery performance**, **stock-out risk**, and **procurement efficiency** — built from hands-on retail operations experience managing stock at The Range (27+ months).

---

## 📌 Business Problem

Retail operations teams face critical challenges in supply chain visibility:
- **Late deliveries** disrupt shop-floor stock availability and customer satisfaction
- **Long supplier lead times** increase working capital requirements
- **Procurement inefficiencies** inflate costs and create excess or shortage scenarios
- **No early-warning system** for potential stock-outs before they happen

This project addresses each of these pain points using structured SQL analysis.

---

## 🗂️ Project Structure

```
supply-chain-analytics/
├── data/
│   └── sample_supplier_data.csv     # 25 supplier records across 5 categories
├── sql/
│   ├── lead_time_analysis.sql        # Supplier lead time benchmarking
│   ├── delivery_performance.sql      # On-time delivery rate by supplier
│   ├── stockout_risk_model.sql       # Predictive stock-out risk scoring
│   └── procurement_efficiency.sql    # Cost-per-unit and order cycle analysis
├── docs/
│   └── findings_report.md            # Key insights and recommendations
├── LICENSE
└── README.md
```

---

## 📊 Key Metrics Tracked

| Metric | Description |
|---|---|
| **Supplier Lead Time** | Days from PO placement to goods receipt |
| **On-Time Delivery Rate** | % of orders delivered by agreed date |
| **Stock-Out Risk Score** | Composite score based on lead time + current stock |
| **Order Cycle Time** | End-to-end procurement process duration |
| **Cost Per Unit** | Effective cost including delivery and handling |
| **Fill Rate** | % of ordered units actually delivered |

---

## 🔍 SQL Analysis Modules

### 1. Lead Time Analysis (`sql/lead_time_analysis.sql`)
- Average, min, max lead time by supplier and category
- Lead time trend analysis (improving/worsening over time)
- Supplier benchmarking against category average

### 2. Delivery Performance (`sql/delivery_performance.sql`)
- On-time delivery rate per supplier
- Late delivery frequency and average delay (days)
- Supplier reliability scoring (A/B/C classification)

### 3. Stock-Out Risk Model (`sql/stockout_risk_model.sql`)
- Composite risk score combining lead time + current stock + sales velocity
- Products flagged as HIGH / MEDIUM / LOW risk
- Recommended order trigger dates

### 4. Procurement Efficiency (`sql/procurement_efficiency.sql`)
- Cost-per-unit analysis by supplier
- Order cycle time breakdown
- Consolidation opportunities (multiple small orders vs. bulk)

---

## 💡 Key Insights

- **Top 20% of suppliers** account for 80% of late deliveries — targeted relationship management can reduce delays by ~35%
- **Electronics accessories** have the highest stock-out risk due to short shelf life and variable lead times
- **Consolidating orders** across Garden and Home Decor categories could reduce procurement costs by an estimated 12–18%
- Suppliers with **lead times >14 days** require safety stock buffer of at least 2x average daily sales

---

## 🛠️ Tools & Technologies

- **SQL** (PostgreSQL-compatible) — all queries
- **Excel / Power BI** — dashboard visualisation
- **GitHub** — version control and portfolio

---

## 👤 Author

**Manoj Kumar Kavuri**  
MSc International Business Management (Distinction)  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/manojkumarkavuri/)  
[![GitHub](https://img.shields.io/badge/GitHub-Profile-black)](https://github.com/manojkumarkavuri20-a11y)

---

*MIT License · Open for collaboration and feedback*
