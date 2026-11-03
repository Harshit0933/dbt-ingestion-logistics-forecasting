{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by={'field': 'target_date', 'data_type': 'date'},
    cluster_by=['zone_id']
) }}

WITH spine AS (
    SELECT * FROM {{ ref('int_geo_date_spine') }}
    {% if is_incremental() %}
        -- Here target_date is an actual column from the upstream spine model
        WHERE target_date >= DATE_SUB(CURRENT_DATE(), INTERVAL {{ var('incremental_lookback_days', 7) }} DAY)
    {% endif %}
),

daily_transactions AS (
    SELECT
        CAST(order_timestamp_utc AS DATE) AS target_date,
        zone_id,
        COUNT(transaction_id) AS total_orders,
        SUM(order_quantity) AS total_items_sold
    FROM {{ ref('stg_raw__transactions') }}
    {% if is_incremental() %}
        -- Here we must filter on the raw column, not the target_date alias
        WHERE CAST(order_timestamp_utc AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL {{ var('incremental_lookback_days', 7) }} DAY)
    {% endif %}
    GROUP BY 1, 2
),

weather AS (
    SELECT * FROM {{ ref('stg_raw__weather_actuals') }}
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
LEFT JOIN daily_transactions t
    ON s.target_date = t.target_date
    AND s.zone_id = t.zone_id
LEFT JOIN weather w
    ON s.target_date = w.target_date
    AND s.zone_id = w.zone_id