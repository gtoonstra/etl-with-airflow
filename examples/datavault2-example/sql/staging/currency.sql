SELECT
      c.currencycode
    , c.name
    , LTRIM(RTRIM(COALESCE(CAST(c.currencycode as varchar), ''))) as hkey_currency
FROM
    sales.currency c
