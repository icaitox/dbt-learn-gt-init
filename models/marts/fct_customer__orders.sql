{{
    config(
        materialized = 'table',
        description = "Fact table for customer orders, joining order, customer, and payment data."
        )
    }}

    -- Import CTEs: These CTEs are used to import and prepare raw data from sources
    with orders as (
        select
            id as order_id,
            user_id as customer_id,
            status as order_status,
            order_date
        from {{ source('jaffle_shop', 'orders') }}
    ),
    customers as (
        select
            id as customer_id,
            first_name,
            last_name
        from {{ source('jaffle_shop', 'customers') }}
    ),
    payments as (
        select
            orderid as order_id,
            status as payment_status,
            amount
        from {{ source('stripe', 'payment') }}
    ),

    -- Logical CTEs: These CTEs perform intermediate transformations and calculations
    customer_order_history as (
        select
            o.customer_id,
            c.first_name,
            c.last_name,
            min(o.order_date) as first_order_date,
            count(*) as order_count,
            sum(case when p.payment_status != 'fail' then round(p.amount/100.0, 2) else 0 end) as total_lifetime_value
        from orders o
        join customers c on o.customer_id = c.customer_id
        left join payments p on o.order_id = p.order_id
        where o.order_status not in ('pending', 'returned', 'return_pending')
        group by o.customer_id, c.first_name, c.last_name
    ),

    -- Final CTEs: These CTEs produce the final output for the model
    final as (
        select
            o.order_id,
            o.customer_id,
            c.last_name as surname,
            c.first_name as givenname,
            coh.first_order_date,
            coh.order_count,
            coh.total_lifetime_value,
            round(p.amount/100.0, 2) as order_value_dollars,
            o.order_status,
            p.payment_status
        from orders o
        join customers c on o.customer_id = c.customer_id
        left join customer_order_history coh on o.customer_id = coh.customer_id
        left join payments p on o.order_id = p.order_id
        where p.payment_status != 'fail'
    )

    select * from final