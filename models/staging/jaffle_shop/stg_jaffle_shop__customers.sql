select
    id as customer_id,
        first_name,
        last_name,
        current_timestamp() as extraction_timestamp

    from {{ source('jaffle_shop', 'customers') }}