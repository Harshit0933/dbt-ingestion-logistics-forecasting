{{ config(materialized='view') }}

SELECT
    CAST(weather_date AS DATE) AS target_date,
    region,
    CAST(temperature_celsius AS NUMERIC) AS temperature_celsius,
    CAST(rainfall_mm AS NUMERIC) AS rainfall_mm,
    CAST(snowfall_cm AS NUMERIC) AS snowfall_cm
FROM {{ source('raw_data', 'weather_actuals') }}
