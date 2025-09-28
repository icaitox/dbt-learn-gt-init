with customer_orders as (
    select 
        customer_id, 
        order_date, 
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'order_date']) }} as primary_key,
        count(*) as order_count
    from 
        {{ ref('stg_jaffle_shop__orders') }}
    group by 
        customer_id, 
        order_date
)
select 
    *
from 
    customer_orders;