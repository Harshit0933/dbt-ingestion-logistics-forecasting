{% macro lag_7d(column_name, partition_by, order_by) %}
    LAG({{ column_name }}, 7) OVER (
        PARTITION BY {{ partition_by }} 
        ORDER BY {{ order_by }}
    )
{% endmacro %}
