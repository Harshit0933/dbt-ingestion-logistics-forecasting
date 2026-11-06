{{ config(materialized='view') }}

SELECT
    zone_id,
    region,
    population_density,
    CAST(dbt_valid_from AS DATE) AS valid_from_date,
    CAST(dbt_valid_to AS DATE) AS valid_to_date,
    dbt_scd_id
FROM {{ ref('snp_zones') }}
