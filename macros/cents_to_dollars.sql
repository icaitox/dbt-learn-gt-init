{%- macro cents_to_dollars(cents, decimals=2) -%}
    (ROUND({{ cents }} / 100.0, {{ decimals }}))
{%- endmacro -%}