select
*,
 {{ get_value_with_tax('amount'), 30 }} as amount_with_tax
from {{ ref('raw_payments') }}