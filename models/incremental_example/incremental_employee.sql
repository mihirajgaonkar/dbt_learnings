{{ 
	config(
	materialized = 'incremental',  
    unique_key = 'id',  
    merge_update_columns = ['position','department']
    )
}}

-- the table is not created again only the new records inserted are added into the table as per the strategy/jinja below, make sure you have already created a table or view before to use incremental 
-- if the config contains unique_key then the column is defined and if any records are updated in the existing table then it checks for the column value in the transformed view/table and updates them 
-- only the specified columns (position and department) are updated


select
*
from {{ source('employee_source', 'EMPLOYEE') }} --the source name and the table name are defined 
where
salary > 50000



{% if is_incremental() %}

    where updated_at > (select max(updated_at) from {{ this }})

{% endif %}