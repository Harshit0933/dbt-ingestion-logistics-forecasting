{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by={'field': 'target_date', 'data_type': 'date'},
    cluster_by=['zone_id']
) }}

WITH spine AS (
    SELECT *
    FROM {{ ref('int_geo_date_spine') }}
    {% if is_incremental() %}
        WHERE target_date >= DATE_SUB(CURRENT_DATE(), INTERVAL {{ var('incremental_lookback_days', 7) }} DAY)
    {% endif %}
),

-- 1. ADDED: Bring in zones to map zone_id to city_id for weather
zones AS (
    SELECT zone_id, city_id
    FROM {{ ref('stg_raw__dim_zones') }}
),

daily_transactions AS (
    SELECT
        -- 2. FIXED: Convert UTC to Berlin timezone before extracting the date
        EXTRACT(DATE FROM order_timestamp_utc AT TIME ZONE 'Europe/Berlin') AS target_date,
        zone_id,
        COUNT(transaction_id) AS total_orders,
        SUM(order_quantity) AS total_items_sold
    FROM {{ ref('stg_raw__transactions') }}
    {% if is_incremental() %}
        WHERE EXTRACT(DATE FROM order_timestamp_utc AT TIME ZONE 'Europe/Berlin') >= DATE_SUB(CURRENT_DATE(), INTERVAL {{ var('incremental_lookback_days', 7) }} DAY)
    {% endif %}
    GROUP BY 1, 2
),

weather AS (
    SELECT *
    FROM {{ ref('stg_raw__weather_actuals') }}
)

SELECT
    s.target_date,
    s.zone_id,
    COALESCE(t.total_orders, 0) AS total_orders,
    COALESCE(t.total_items_sold, 0) AS total_items_sold,
    w.temperature_celsius,
    w.precipitation_mm,
    {{ rolling_avg_7d('t.total_orders', 's.zone_id', 's.target_date') }} AS rolling_7d_avg_orders
FROM spine s
-- 3. FIXED: Join zones first, then join weather on city_id instead of zone_id
LEFT JOIN zones z
    ON s.zone_id = z.zone_id
LEFT JOIN daily_transactions t
    ON s.target_date = t.target_date
    AND s.zone_id = t.zone_id
LEFT JOIN weather w
    ON s.target_date = w.target_date 
    AND z.city_id = w.city_id
