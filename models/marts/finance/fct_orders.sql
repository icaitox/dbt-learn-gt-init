-- models/marts/finance/fct_orders.sql
-- Fact table: one row per order, joined with Stripe payment info when available

with orders as (
    select
        o.order_id as order_id,
        o.customer_id,
        o.order_date as order_created_at
    from {{ ref('stg_jaffle_shop__orders') }} as o
),

payments as (
    select
        -- attempt common order id columns that could exist in the payments staging
        p.order_id,
        p.payment_id,
        p.status as payment_status,
        p.amount as payment_amount,
        p.created_at as paid_at
    from {{ ref('stg_stripe__payments') }} as p
)

select
    o.order_id,
    o.customer_id,
    p.payment_amount

from orders o
left join payments p using (order_id)