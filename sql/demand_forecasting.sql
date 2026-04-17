-- ============================================================
-- Demand Forecasting & Planning Analytics
-- Project: Supply Chain Analytics
-- Author:  Manoj Kumar Kavuri
-- Description: Moving averages, seasonality detection,
--              reorder point calculation and safety stock
-- ============================================================

-- 1. MOVING AVERAGE DEMAND FORECAST
-- 4-week and 12-week moving averages to smooth demand signal
WITH weekly_sales AS (
    SELECT
        product_id,
        DATE_TRUNC('week', sale_date)           AS sale_week,
        SUM(quantity_sold)                      AS weekly_qty
    FROM sales
    WHERE sale_date >= CURRENT_DATE - INTERVAL '26 weeks'
    GROUP BY product_id, DATE_TRUNC('week', sale_date)
)
SELECT
    product_id,
    sale_week,
    weekly_qty,
    ROUND(AVG(weekly_qty)
        OVER (PARTITION BY product_id
              ORDER BY sale_week
              ROWS BETWEEN 3 PRECEDING AND CURRENT ROW), 1) AS ma_4_week,
    ROUND(AVG(weekly_qty)
        OVER (PARTITION BY product_id
              ORDER BY sale_week
              ROWS BETWEEN 11 PRECEDING AND CURRENT ROW), 1) AS ma_12_week,
    ROUND(STDDEV(weekly_qty)
        OVER (PARTITION BY product_id
              ORDER BY sale_week
              ROWS BETWEEN 11 PRECEDING AND CURRENT ROW), 1) AS demand_stddev_12w
FROM weekly_sales
ORDER BY product_id, sale_week;


-- 2. SEASONALITY INDEX
-- Compares each month's demand vs annual average to detect patterns
WITH monthly_sales AS (
    SELECT
        product_id,
        EXTRACT(MONTH FROM sale_date)           AS sale_month,
        EXTRACT(YEAR FROM sale_date)            AS sale_year,
        SUM(quantity_sold)                      AS monthly_qty
    FROM sales
    WHERE sale_date >= CURRENT_DATE - INTERVAL '2 years'
    GROUP BY product_id,
             EXTRACT(MONTH FROM sale_date),
             EXTRACT(YEAR FROM sale_date)
),
annual_avg AS (
    SELECT
        product_id,
        sale_year,
        AVG(monthly_qty)                        AS avg_monthly_qty
    FROM monthly_sales
    GROUP BY product_id, sale_year
)
SELECT
    m.product_id,
    m.sale_month,
    ROUND(AVG(m.monthly_qty), 0)                AS avg_monthly_demand,
    ROUND(AVG(a.avg_monthly_qty), 0)            AS annual_monthly_avg,
    ROUND(
        AVG(m.monthly_qty)
        / NULLIF(AVG(a.avg_monthly_qty), 0), 2
    )                                           AS seasonality_index,
    CASE
        WHEN ROUND(AVG(m.monthly_qty)
             / NULLIF(AVG(a.avg_monthly_qty), 0), 2) > 1.20  THEN 'Peak Season'
        WHEN ROUND(AVG(m.monthly_qty)
             / NULLIF(AVG(a.avg_monthly_qty), 0), 2) < 0.80  THEN 'Low Season'
        ELSE                                                       'Normal'
    END                                         AS season_flag
FROM monthly_sales m
JOIN annual_avg a
    ON m.product_id = a.product_id
    AND m.sale_year = a.sale_year
GROUP BY m.product_id, m.sale_month
ORDER BY m.product_id, m.sale_month;


-- 3. REORDER POINT CALCULATION
-- ROP = (Avg Daily Demand x Lead Time) + Safety Stock
-- Safety Stock = Z * StdDev(demand) * sqrt(lead_time)
WITH demand_stats AS (
    SELECT
        product_id,
        ROUND(AVG(quantity_sold), 2)            AS avg_daily_demand,
        ROUND(STDDEV(quantity_sold), 2)         AS stddev_daily_demand
    FROM sales
    WHERE sale_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY product_id
),
lead_time_stats AS (
    SELECT
        product_id,
        ROUND(AVG(lead_time_days), 1)           AS avg_lead_time,
        ROUND(STDDEV(lead_time_days), 1)        AS stddev_lead_time
    FROM purchase_orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY product_id
)
SELECT
    d.product_id,
    p.product_name,
    p.category,
    d.avg_daily_demand,
    d.stddev_daily_demand,
    l.avg_lead_time,
    -- Safety Stock using 95% service level (Z = 1.645)
    ROUND(
        1.645 * d.stddev_daily_demand
        * SQRT(l.avg_lead_time), 0
    )                                           AS safety_stock_units,
    -- Reorder Point
    ROUND(
        (d.avg_daily_demand * l.avg_lead_time)
        + (1.645 * d.stddev_daily_demand * SQRT(l.avg_lead_time)), 0
    )                                           AS reorder_point,
    -- Economic Order Quantity (basic EOQ: sqrt(2DS/H))
    -- D = annual demand, S = order cost (£25), H = holding cost (20% of unit price)
    ROUND(
        SQRT(
            (2 * d.avg_daily_demand * 365 * 25)
            / NULLIF(p.unit_cost * 0.20, 0)
        ), 0
    )                                           AS eoq_units
FROM demand_stats d
JOIN lead_time_stats l ON d.product_id = l.product_id
JOIN products p ON d.product_id = p.product_id
ORDER BY d.avg_daily_demand * l.avg_lead_time DESC;


-- 4. DEMAND VARIANCE ALERT
-- Flags products where actual demand is deviating significantly
-- from the forecast (4-week moving average)
WITH recent_weekly AS (
    SELECT
        product_id,
        DATE_TRUNC('week', sale_date)           AS sale_week,
        SUM(quantity_sold)                      AS actual_qty
    FROM sales
    WHERE sale_date >= CURRENT_DATE - INTERVAL '8 weeks'
    GROUP BY product_id, DATE_TRUNC('week', sale_date)
),
with_forecast AS (
    SELECT
        product_id,
        sale_week,
        actual_qty,
        ROUND(AVG(actual_qty)
            OVER (PARTITION BY product_id
                  ORDER BY sale_week
                  ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING), 1) AS forecast_qty
    FROM recent_weekly
)
SELECT
    product_id,
    sale_week,
    actual_qty,
    forecast_qty,
    ROUND(actual_qty - forecast_qty, 0)         AS variance,
    ROUND(
        (actual_qty - forecast_qty)
        / NULLIF(forecast_qty, 0) * 100, 1
    )                                           AS variance_pct,
    CASE
        WHEN ABS((actual_qty - forecast_qty)
             / NULLIF(forecast_qty, 0)) > 0.30  THEN 'High Variance - Review'
        WHEN ABS((actual_qty - forecast_qty)
             / NULLIF(forecast_qty, 0)) > 0.15  THEN 'Moderate Variance'
        ELSE                                         'Within Tolerance'
    END                                         AS alert_flag
FROM with_forecast
WHERE forecast_qty IS NOT NULL
ORDER BY ABS(variance_pct) DESC NULLS LAST;
