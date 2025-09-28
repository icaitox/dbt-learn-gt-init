with payments as (

    select * 
    from {{ ref('stg_stripe__payments') }}
    where status = 'success'
),
pivoted as (

    select 
        order_id
        , {% for method in ['bank_transfer', 'coupon', 'credit_card', 'gift_card'] %}
            sum(case when payment_method = '{{ method }}' then amount else 0 end) as {{ method }}_amount
            {%- if not loop.last -%},{%- endif -%}
        {% endfor %}
        -- , sum(case when payment_method = 'bank_transfer' then amount else 0 end) as bank_transfer_amount
        -- , sum(case when payment_method = 'coupon' then amount else 0 end) as coupon_amount
        -- , sum(case when payment_method = 'credit_card' then amount else 0 end) as credit_card_amount
        -- , sum(case when payment_method = 'gift_card' then amount else 0 end) as gift_card_amount
    from payments
    group by order_id
)
select * 
from pivoted