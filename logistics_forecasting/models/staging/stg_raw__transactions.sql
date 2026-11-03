{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw_data', 'transactions') }}
),

renamed AS (
    SELECT
        transaction_id,
        -- Standardize timestamps to UTC for ML consistency
        TIMESTAMP(order_timestamp) AS order_timestamp_utc,
        customer_id,
        zone_id,
        item_id,
        applied_promo_id,
        CAST(quantity AS INT64) AS order_quantity
    FROM source
)

SELECT * FROM renamed
