with temp as (
select
EMPLOYEE_ID, SUM(SALES_AMOUNT) as TOTAL_SALES
from {{ source('employee_sales_source', 'SALES_DATA') }} --the source name and the table name are defined 
GROUP BY 1
)

SELECT
    EMPLOYEE_ID,
    TOTAL_SALES,
    (CASE
        WHEN TOTAL_SALES >= {{ var('sales_expectation') }} THEN 1 ELSE 0 
    END) AS SALES_EXPECTATION_STATUS
FROM
    temp