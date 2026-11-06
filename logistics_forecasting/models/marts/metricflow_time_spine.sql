{{ config(materialized='table') }}

-- MetricFlow requires a dedicated date table spanning several years 
-- in the past and future with a column specifically named 'date_day'

SELECT
    CAST(date_day AS DATE) AS date_day
FROM UNNEST(GENERATE_DATE_ARRAY('2020-01-01', '2030-12-31', INTERVAL 1 DAY)) AS date_day
