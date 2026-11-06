SELECT 
    CAST(target_date AS DATE) AS target_date,
    city,
    holiday_name
FROM {{ ref('public_holidays') }}
