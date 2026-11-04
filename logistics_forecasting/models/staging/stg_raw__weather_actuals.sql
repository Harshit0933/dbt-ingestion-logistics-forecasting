{{ config(materialized='view') }}

SELECT
    CAST(weather_date AS DATE) AS target_date,
    region, 
    CAST(temperature_celsius AS NUMERIC) AS temperature_celsius,
    CAST(precipitation_mm AS NUMERIC) AS precipitation_mm
FROM {{ source('raw_data', 'weather_actuals') }}
