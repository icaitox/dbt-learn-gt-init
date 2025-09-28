{%- macro cents_to_dollars(cents, decimals=2) -%}
    round({{ cents }} / 100.0, {{ decimals }})
{%- endmacro -%}