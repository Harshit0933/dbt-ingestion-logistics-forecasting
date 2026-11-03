{% macro rolling_avg_7d(column_name, partition_by, order_by) %}
    AVG({{ column_name }}) OVER (
        PARTITION BY {{ partition_by }} 
        ORDER BY UNIX_DATE({{ order_by }}) 
        RANGE BETWEEN 6 PRECEDING AND CURRENT ROW
    )
{% endmacro %}
