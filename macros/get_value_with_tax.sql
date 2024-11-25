{% macro get_value_with_tax(amount_column, tax_percent = 12) %}


    round({{amount_column}} + {{amount_column}} * {{tax_percent}} / 100)


{% endmacro %}