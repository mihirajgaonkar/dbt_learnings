select
order_id,
{% for payment_method in get_payment_methods() %}
sum(case when payment_method = '{{payment_method}}' then amount end) as {{payment_method}}_amount
{% if not loop.last %},{% endif %} -- to remove the last comma
{% endfor %}
from {{ ref('raw_payments') }}
group by 1