-- ============================================================
-- Stockout Risk & Inventory Health Analysis
-- Project: Supply Chain Analytics
-- Author:  Manoj Kumar Kavuri
-- Description: Identifies products at risk of stockout,
--              ABC classification, and replenishment urgency
-- ============================================================

-- 1. CURRENT STOCKOUT RISK ASSESSMENT
-- Calculates days of stock remaining vs reorder lead time
WITH daily_demand AS (
    SELECT
        product_id,
        ROUND(AVG(quantity_sold), 2)              AS avg_daily_demand
    FROM sales
    WHERE sale_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY product_id
),
avg_lead_time AS (
    SELECT
        product_id,
        ROUND(AVG(lead_time_days), 0)             AS avg_lead_time_days
    FROM purchase_orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY product_id
)
SELECT
    i.product_id,
    p.product_name,
    p.category,
    i.quantity_on_hand,
    d.avg_daily_demand,
    l.avg_lead_time_days,
    -- Days of stock remaining
    ROUND(
        i.quantity_on_hand
        / NULLIF(d.avg_daily_demand, 0), 0
    )                                             AS days_of_stock,
    -- Stock coverage vs lead time
    ROUND(
        i.quantity_on_hand / NULLIF(d.avg_daily_demand, 0)
        - l.avg_lead_time_days, 0
    )                                             AS coverage_buffer_days,
    CASE
        WHEN i.quantity_on_hand = 0
            THEN 'STOCKOUT NOW'
        WHEN ROUND(i.quantity_on_hand / NULLIF(d.avg_daily_demand, 0), 0)
             <= l.avg_lead_time_days
            THEN 'CRITICAL - Order Immediately'
        WHEN ROUND(i.quantity_on_hand / NULLIF(d.avg_daily_demand, 0), 0)
             <= l.avg_lead_time_days * 1.5
            THEN 'WARNING - Order Soon'
        WHEN ROUND(i.quantity_on_hand / NULLIF(d.avg_daily_demand, 0), 0)
             <= l.avg_lead_time_days * 2
            THEN 'WATCH - Monitor Closely'
        ELSE
            'OK'
    END                                           AS stock_status
FROM inventory i
JOIN daily_demand d ON i.product_id = d.product_id
JOIN avg_lead_time l ON i.product_id = l.product_id
JOIN products p ON i.product_id = p.product_id
ORDER BY
    CASE
        WHEN i.quantity_on_hand = 0 THEN 1
        WHEN ROUND(i.quantity_on_hand / NULLIF(d.avg_daily_demand, 0), 0)
             <= l.avg_lead_time_days THEN 2
        WHEN ROUND(i.quantity_on_hand / NULLIF(d.avg_daily_demand, 0), 0)
             <= l.avg_lead_time_days * 1.5 THEN 3
        ELSE 4
    END,
    days_of_stock ASC;


-- 2. ABC INVENTORY CLASSIFICATION
-- Segments SKUs by revenue contribution (Pareto principle)
-- A = top 80% of revenue, B = next 15%, C = bottom 5%
WITH revenue_by_sku AS (
    SELECT
        s.product_id,
        p.product_name,
        p.category,
        SUM(s.quantity_sold * s.unit_price)       AS total_revenue,
        SUM(s.quantity_sold)                      AS total_units_sold
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    WHERE s.sale_date >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY s.product_id, p.product_name, p.category
),
ranked AS (
    SELECT
        *,
        SUM(total_revenue) OVER ()                AS grand_total_revenue,
        SUM(total_revenue) OVER (
            ORDER BY total_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                                         AS cumulative_revenue
    FROM revenue_by_sku
)
SELECT
    product_id,
    product_name,
    category,
    ROUND(total_revenue, 2)                       AS total_revenue,
    total_units_sold,
    ROUND(total_revenue / grand_total_revenue * 100, 2)
                                                  AS revenue_share_pct,
    ROUND(cumulative_revenue / grand_total_revenue * 100, 2)
                                                  AS cumulative_pct,
    CASE
        WHEN cumulative_revenue / grand_total_revenue <= 0.80 THEN 'A - Critical'
        WHEN cumulative_revenue / grand_total_revenue <= 0.95 THEN 'B - Important'
        ELSE                                                       'C - Low Priority'
    END                                           AS abc_class
FROM ranked
ORDER BY total_revenue DESC;


-- 3. STOCKOUT HISTORY & FREQUENCY
-- Identifies repeat offenders with chronic stockout problems
SELECT
    s.product_id,
    p.product_name,
    p.category,
    COUNT(*)                                      AS stockout_events,
    MIN(s.stockout_date)                          AS first_stockout,
    MAX(s.stockout_date)                          AS last_stockout,
    ROUND(AVG(s.days_out_of_stock), 1)            AS avg_days_per_stockout,
    SUM(s.days_out_of_stock)                      AS total_days_out_of_stock,
    -- Estimated lost revenue (avg daily demand x unit price x days out)
    ROUND(
        AVG(d.avg_daily_demand) * p.unit_price
        * SUM(s.days_out_of_stock), 2
    )                                             AS est_lost_revenue_gbp
FROM stockout_events s
JOIN products p ON s.product_id = p.product_id
JOIN (
    SELECT product_id, AVG(quantity_sold) AS avg_daily_demand
    FROM sales
    WHERE sale_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY product_id
) d ON s.product_id = d.product_id
WHERE s.stockout_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY s.product_id, p.product_name, p.category, p.unit_price
HAVING COUNT(*) >= 2
ORDER BY total_days_out_of_stock DESC;


-- 4. OVERSTOCK IDENTIFICATION
-- Finds products with excess inventory tying up working capital
WITH demand_and_stock AS (
    SELECT
        i.product_id,
        p.product_name,
        p.category,
        p.unit_cost,
        i.quantity_on_hand,
        COALESCE(d.avg_daily_demand, 0)           AS avg_daily_demand,
        ROUND(
            i.quantity_on_hand
            / NULLIF(d.avg_daily_demand, 0), 0
        )                                         AS days_of_stock
    FROM inventory i
    JOIN products p ON i.product_id = p.product_id
    LEFT JOIN (
        SELECT product_id, AVG(quantity_sold) AS avg_daily_demand
        FROM sales
        WHERE sale_date >= CURRENT_DATE - INTERVAL '90 days'
        GROUP BY product_id
    ) d ON i.product_id = d.product_id
)
SELECT
    product_id,
    product_name,
    category,
    quantity_on_hand,
    avg_daily_demand,
    days_of_stock,
    ROUND(quantity_on_hand * unit_cost, 2)        AS stock_value_gbp,
    -- Excess units beyond 90-day supply
    GREATEST(
        ROUND(quantity_on_hand - (avg_daily_demand * 90), 0), 0
    )                                             AS excess_units,
    GREATEST(
        ROUND((quantity_on_hand - (avg_daily_demand * 90)) * unit_cost, 2), 0
    )                                             AS excess_stock_value_gbp,
    CASE
        WHEN days_of_stock > 180  THEN 'Severe Overstock - Liquidate'
        WHEN days_of_stock > 90   THEN 'Overstock - Reduce Orders'
        WHEN days_of_stock > 60   THEN 'Elevated Stock - Monitor'
        ELSE                           'Healthy'
    END                                           AS overstock_flag
FROM demand_and_stock
WHERE days_of_stock > 60
  AND quantity_on_hand > 0
ORDER BY excess_stock_value_gbp DESC;
