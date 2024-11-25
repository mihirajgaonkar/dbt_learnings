select

*

from {{ source('employee_source', 'EMPLOYEE') }} --the source name and the table name are defined 

where

salary > 50000

--this is how you can define multiple sources, perform transformations and create a model using dbt in the target schema 