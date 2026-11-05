{{ config(materialized='view') }}

SELECT
    CAST(w.weather_date AS DATE) AS target_date,
    z.region,
    CAST(w.temperature_celsius AS NUMERIC) AS temperature_celsius,
    CAST(w.precipitation_mm AS NUMERIC) AS precipitation_mm,
    CAST(rainfall_mm AS NUMERIC) AS rainfall_mm,
    CAST(snowfall_cm AS NUMERIC) AS snowfall_cm 
FROM {{ source('raw_data', 'weather_actuals') }} w
