{{ config(
    materialized='table',
    partition_by={'field': 'target_date', 'data_type': 'date'},
    cluster_by=['zone_id']
) }}

WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="CAST('2023-01-01' AS DATE)",
        end_date="CURRENT_DATE()"
    ) }}
),

active_zones AS (
    SELECT DISTINCT zone_id 
    FROM {{ ref('stg_raw__dim_zones') }}
)

-- Cross join creates a row for every zone for every single day
SELECT
    CAST(d.date_day AS DATE) AS target_date,
    z.zone_id
FROM date_spine d
CROSS JOIN active_zones z
