-- ============================================================
-- Supplier Performance Analysis
-- Project: Supply Chain Analytics
-- Author:  Manoj Kumar Kavuri
-- Description: Evaluates supplier reliability, lead time
--              consistency, fill rates and quality metrics
-- ============================================================

-- 1. SUPPLIER SCORECARD
-- Overall performance ranking across all key dimensions
SELECT
    s.supplier_id,
    s.supplier_name,
    s.country,
    s.category,
    COUNT(po.order_id)                                        AS total_orders,
    ROUND(AVG(po.lead_time_days), 1)                          AS avg_lead_time_days,
    ROUND(STDDEV(po.lead_time_days), 1)                       AS lead_time_stddev,
    ROUND(
        COUNT(CASE WHEN po.delivered_date <= po.promised_date
              THEN 1 END)::DECIMAL
        / NULLIF(COUNT(po.order_id), 0) * 100, 1
    )                                                         AS on_time_delivery_pct,
    ROUND(
        SUM(po.quantity_received)::DECIMAL
        / NULLIF(SUM(po.quantity_ordered), 0) * 100, 1
    )                                                         AS fill_rate_pct,
    ROUND(
        SUM(po.quantity_defective)::DECIMAL
        / NULLIF(SUM(po.quantity_received), 0) * 100, 2
    )                                                         AS defect_rate_pct,
    ROUND(AVG(po.unit_cost), 2)                               AS avg_unit_cost,
    -- Composite Score (weighted: 40% OTD, 30% fill rate, 30% quality)
    ROUND(
        (
            COUNT(CASE WHEN po.delivered_date <= po.promised_date
                  THEN 1 END)::DECIMAL
            / NULLIF(COUNT(po.order_id), 0) * 100 * 0.40
        ) + (
            SUM(po.quantity_received)::DECIMAL
            / NULLIF(SUM(po.quantity_ordered), 0) * 100 * 0.30
        ) + (
            (1 - SUM(po.quantity_defective)::DECIMAL
             / NULLIF(SUM(po.quantity_received), 0)) * 100 * 0.30
        ), 1
    )                                                         AS composite_score
FROM suppliers s
JOIN purchase_orders po ON s.supplier_id = po.supplier_id
WHERE po.order_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY s.supplier_id, s.supplier_name, s.country, s.category
ORDER BY composite_score DESC;


-- 2. SUPPLIER RISK CLASSIFICATION
-- Segments suppliers into risk tiers for procurement strategy
WITH supplier_stats AS (
    SELECT
        s.supplier_id,
        s.supplier_name,
        s.category,
        ROUND(
            COUNT(CASE WHEN po.delivered_date <= po.promised_date
                  THEN 1 END)::DECIMAL
            / NULLIF(COUNT(po.order_id), 0) * 100, 1
        )                                                     AS on_time_pct,
        ROUND(
            SUM(po.quantity_received)::DECIMAL
            / NULLIF(SUM(po.quantity_ordered), 0) * 100, 1
        )                                                     AS fill_rate_pct,
        ROUND(
            SUM(po.quantity_defective)::DECIMAL
            / NULLIF(SUM(po.quantity_received), 0) * 100, 2
        )                                                     AS defect_rate_pct
    FROM suppliers s
    JOIN purchase_orders po ON s.supplier_id = po.supplier_id
    WHERE po.order_date >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY s.supplier_id, s.supplier_name, s.category
)
SELECT
    *,
    CASE
        WHEN on_time_pct >= 95 AND fill_rate_pct >= 98
             AND defect_rate_pct < 1                          THEN 'Preferred'
        WHEN on_time_pct >= 85 AND fill_rate_pct >= 93
             AND defect_rate_pct < 3                          THEN 'Approved'
        WHEN on_time_pct >= 75 AND fill_rate_pct >= 85        THEN 'Conditional'
        ELSE                                                       'At Risk'
    END                                                       AS risk_tier,
    CASE
        WHEN on_time_pct < 75                                 THEN 'Poor OTD'
        WHEN fill_rate_pct < 85                               THEN 'Low Fill Rate'
        WHEN defect_rate_pct >= 3                             THEN 'High Defect Rate'
        ELSE                                                       'No Primary Issue'
    END                                                       AS primary_issue
FROM supplier_stats
ORDER BY on_time_pct ASC;


-- 3. MONTH-OVER-MONTH SUPPLIER TREND
-- Tracks whether supplier performance is improving or declining
WITH monthly_perf AS (
    SELECT
        s.supplier_id,
        s.supplier_name,
        DATE_TRUNC('month', po.order_date)                    AS order_month,
        ROUND(
            COUNT(CASE WHEN po.delivered_date <= po.promised_date
                  THEN 1 END)::DECIMAL
            / NULLIF(COUNT(po.order_id), 0) * 100, 1
        )                                                     AS on_time_pct
    FROM suppliers s
    JOIN purchase_orders po ON s.supplier_id = po.supplier_id
    WHERE po.order_date >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY s.supplier_id, s.supplier_name, DATE_TRUNC('month', po.order_date)
)
SELECT
    supplier_id,
    supplier_name,
    order_month,
    on_time_pct,
    LAG(on_time_pct) OVER (PARTITION BY supplier_id ORDER BY order_month)
                                                              AS prev_month_pct,
    ROUND(
        on_time_pct
        - LAG(on_time_pct) OVER (PARTITION BY supplier_id ORDER BY order_month)
    , 1)                                                      AS mom_change_pct,
    CASE
        WHEN on_time_pct > LAG(on_time_pct)
             OVER (PARTITION BY supplier_id ORDER BY order_month)
            THEN 'Improving'
        WHEN on_time_pct < LAG(on_time_pct)
             OVER (PARTITION BY supplier_id ORDER BY order_month)
            THEN 'Declining'
        ELSE 'Stable'
    END                                                       AS trend
FROM monthly_perf
ORDER BY supplier_id, order_month;


-- 4. COST VARIANCE ANALYSIS
-- Identifies suppliers charging above agreed contract price
SELECT
    s.supplier_name,
    p.product_name,
    po.order_date,
    po.unit_cost                                              AS actual_cost,
    c.agreed_unit_cost                                        AS contract_cost,
    ROUND(po.unit_cost - c.agreed_unit_cost, 2)               AS cost_variance,
    ROUND(
        (po.unit_cost - c.agreed_unit_cost)
        / NULLIF(c.agreed_unit_cost, 0) * 100, 1
    )                                                         AS variance_pct,
    ROUND(
        (po.unit_cost - c.agreed_unit_cost) * po.quantity_ordered, 2
    )                                                         AS total_overcharge_gbp
FROM purchase_orders po
JOIN suppliers s ON po.supplier_id = s.supplier_id
JOIN products p ON po.product_id = p.product_id
JOIN supplier_contracts c
    ON po.supplier_id = c.supplier_id
    AND po.product_id = c.product_id
WHERE po.unit_cost > c.agreed_unit_cost
  AND po.order_date >= CURRENT_DATE - INTERVAL '12 months'
ORDER BY total_overcharge_gbp DESC;
