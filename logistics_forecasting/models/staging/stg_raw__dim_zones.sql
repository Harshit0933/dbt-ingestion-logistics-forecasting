{{ config(materialized='view') }}

SELECT
    zone_id,
    region,
    CAST(population_density AS INT64) AS population_density
FROM {{ source('raw_data', 'dim_zones') }}
