INSERT INTO TABLE dv_raw.link_currencyrate
SELECT DISTINCT
    cr.hkey_currencyrate,
    cr.hkey_currency_fromcurrencycode,
    cr.hkey_currency_tocurrencycode,
    cr.record_source,
    cr.load_dtm
FROM
           advworks_staging.currencyrate_{{ts_nodash}} cr
WHERE
    NOT EXISTS (
        SELECT 
                l.hkey_currencyrate
        FROM    dv_raw.link_currencyrate l
        WHERE 
                l.hkey_currency_fromcurrencycode = cr.hkey_currency_fromcurrencycode
        AND     l.hkey_currency_tocurrencycode = cr.hkey_currency_tocurrencycode
    )
