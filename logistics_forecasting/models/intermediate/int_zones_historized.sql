WITH staged_zones AS (
    SELECT * FROM {{ ref('stg_raw__dim_zones') }}
),

numbered_versions AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY zone_id ORDER BY valid_from_date) AS version_number
    FROM staged_zones
)

SELECT
    zone_id,
    region,
    population_density,
    -- Backdate the very first record to 2020 so it covers all historical transactions
    CASE 
        WHEN version_number = 1 THEN DATE('2020-01-01') 
        ELSE valid_from_date 
    END AS valid_from_date,
    valid_to_date,
    dbt_scd_id
FROM numbered_versions
    