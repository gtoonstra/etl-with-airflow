INSERT INTO TABLE dv_raw.sat_currency
SELECT DISTINCT
      c.hkey_currency
    , c.load_dtm
    , NULL
    , c.record_source
    , c.name
FROM
                advworks_staging.currency_{{ts_nodash}} c
LEFT OUTER JOIN dv_raw.sat_currency sat ON (
                sat.hkey_currency = c.hkey_currency
            AND sat.load_end_dtm IS NULL)
WHERE
    COALESCE(c.name, '') != COALESCE(sat.name, '')
