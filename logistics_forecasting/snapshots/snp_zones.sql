{% snapshot snp_zones %}

{{ config(target_schema='snapshots', unique_key='zone_id', strategy='check', check_cols=['population_density']) }}

SELECT 
    zone_id,
    region,
    population_density
FROM {{ source('raw_data', 'dim_zones') }}

{% endsnapshot %}
