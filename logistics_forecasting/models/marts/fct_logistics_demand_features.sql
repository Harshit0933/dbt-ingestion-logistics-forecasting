{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by={'field': 'target_date', 'data_type': 'date'},
    cluster_by=['zone_id'],
    on_schema_change='sync_all_columns'
) }}

WITH spine AS (
    SELECT *
    FROM {{ ref('int_geo_date_spine') }}
    {% if is_incremental() %}
        WHERE target_date >= DATE_SUB(CURRENT_DATE(), INTERVAL {{ var('incremental_lookback_days', 7) }} DAY)
    {% endif %}
),

zones AS (
    SELECT zone_id, region
    FROM {{ ref('stg_raw__dim_zones') }}
),

daily_transactions AS (
    SELECT
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
),

holidays AS (
    SELECT * FROM {{ ref('int_city_holidays_expanded') }}
)

SELECT
    s.target_date,
    s.zone_id,
    z.region AS city,
    COALESCE(t.total_orders, 0) AS total_orders,
    COALESCE(t.total_items_sold, 0) AS total_items_sold,
    w.temperature_celsius,
    w.rainfall_mm,
    w.snowfall_cm,
    {{ rolling_avg_7d('t.total_orders', 's.zone_id', 's.target_date') }} AS rolling_7d_avg_orders,
    {{ lag_7d('COALESCE(t.total_orders, 0)', 's.zone_id', 's.target_date') }} AS orders_lag_7d,
    h_today.holiday_name,
    CASE WHEN h_today.holiday_date IS NOT NULL THEN 1 ELSE 0 END AS is_holiday,
    CASE WHEN h_tomorrow.day_before_holiday IS NOT NULL THEN 1 ELSE 0 END AS is_day_before_holiday,
    CASE WHEN h_yesterday.day_after_holiday IS NOT NULL THEN 1 ELSE 0 END AS is_day_after_holiday
FROM spine s
LEFT JOIN {{ ref('stg_raw__dim_zones') }} z 
    ON s.zone_id = z.zone_id
LEFT JOIN daily_transactions t
    ON s.target_date = t.target_date
    AND s.zone_id = t.zone_id
LEFT JOIN weather w
    ON s.target_date = w.target_date 
    AND z.region = w.region
LEFT JOIN holidays h_today
    ON s.target_date = h_today.holiday_date
    AND z.region = h_today.city
LEFT JOIN holidays h_tomorrow
    ON s.target_date = h_tomorrow.day_before_holiday
    AND z.region = h_tomorrow.city
LEFT JOIN holidays h_yesterday
    ON s.target_date = h_yesterday.day_after_holiday
    AND z.region = h_yesterday.city
