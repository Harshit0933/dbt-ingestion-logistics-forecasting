{{ config(materialized='view') }}

WITH unique_holidays AS (
    SELECT DISTINCT 
        target_date,
        city,
        holiday_name
    FROM {{ ref('stg_raw__public_holidays') }}
)

SELECT
    city,
    target_date AS holiday_date,
    holiday_name
    DATE_SUB(target_date, INTERVAL 1 DAY) AS day_before_holiday,
    DATE_ADD(target_date, INTERVAL 1 DAY) AS day_after_holiday
FROM unique_holidays
