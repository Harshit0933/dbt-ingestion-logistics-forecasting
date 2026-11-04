{{ config(materialized='view') }}

SELECT
    CAST(w.weather_date AS DATE) AS target_date,
    z.region,
    CAST(w.temperature_celsius AS NUMERIC) AS temperature_celsius,
    CAST(w.precipitation_mm AS NUMERIC) AS precipitation_mm
FROM {{ source('raw_data', 'weather_actuals') }} w
LEFT JOIN {{ source('raw_data', 'dim_zones') }} z
    ON w.zone_id = z.zone_id
    