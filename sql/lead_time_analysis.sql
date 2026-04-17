-- ============================================================
-- lead_time_analysis.sql
-- Supply Chain Analytics
-- Purpose: Benchmark supplier lead times and identify outliers
-- Author:  Manoj Kumar Kavuri
-- ============================================================

-- Step 1: Calculate lead time statistics per supplier
WITH supplier_lead_times AS (
  SELECT
    po.supplier_id,
    s.supplier_name,
    s.category,
    s.country_of_origin,
    COUNT(po.po_id)                       AS total_orders,
    ROUND(AVG(po.lead_time_days), 1)      AS avg_lead_time,
    MIN(po.lead_time_days)                AS min_lead_time,
    MAX(po.lead_time_days)                AS max_lead_time,
    ROUND(STDDEV(po.lead_time_days), 1)   AS lead_time_stddev
  FROM purchase_orders po
  JOIN suppliers s ON po.supplier_id = s.supplier_id
  WHERE po.order_date >= CURRENT_DATE - INTERVAL '12 months'
  GROUP BY po.supplier_id, s.supplier_name, s.category, s.country_of_origin
),

-- Step 2: Category averages for benchmarking
category_avg AS (
  SELECT
    category,
    ROUND(AVG(avg_lead_time), 1) AS category_avg_lead_time
  FROM supplier_lead_times
  GROUP BY category
)

-- Step 3: Final benchmarked output
SELECT
  slt.supplier_id,
  slt.supplier_name,
  slt.category,
  slt.country_of_origin,
  slt.total_orders,
  slt.avg_lead_time,
  slt.min_lead_time,
  slt.max_lead_time,
  slt.lead_time_stddev,
  ca.category_avg_lead_time,
  ROUND(slt.avg_lead_time - ca.category_avg_lead_time, 1) AS days_vs_category_avg,
  CASE
    WHEN slt.avg_lead_time <= ca.category_avg_lead_time * 0.85 THEN 'FAST'
    WHEN slt.avg_lead_time <= ca.category_avg_lead_time * 1.15 THEN 'AVERAGE'
    ELSE 'SLOW'
  END AS lead_time_rating
FROM supplier_lead_times slt
JOIN category_avg ca ON slt.category = ca.category
ORDER BY slt.category, slt.avg_lead_time ASC;

-- ============================================================
-- Use case: Identify slow suppliers for renegotiation
-- Filter: WHERE lead_time_rating = 'SLOW'
-- ============================================================
