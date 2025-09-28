with payments as (

    select * 
    from {{ ref('stg_stripe__payments') }}
    where status = 'success'
)
select * 
from payments