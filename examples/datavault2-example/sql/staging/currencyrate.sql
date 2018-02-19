SELECT
      cr.currencyrateid
    , cr.currencyratedate
    , cr.fromcurrencycode
    , cr.tocurrencycode
    , cr.averagerate
    , cr.endofdayrate
    , CONCAT(
        LTRIM(RTRIM(COALESCE(CAST(cr.fromcurrencycode as varchar), ''))), ';'
      , LTRIM(RTRIM(COALESCE(CAST(cr.tocurrencycode as varchar), '')))
    ) as hkey_currencyrate
    , LTRIM(RTRIM(COALESCE(CAST(cr.fromcurrencycode as varchar), ''))) as hkey_currency_fromcurrencycode
    , LTRIM(RTRIM(COALESCE(CAST(cr.tocurrencycode as varchar), ''))) as hkey_currency_tocurrencycode
FROM
    sales.currencyrate cr
