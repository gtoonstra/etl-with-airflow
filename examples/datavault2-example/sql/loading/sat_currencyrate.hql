INSERT INTO TABLE dv_raw.sat_currencyrate
SELECT DISTINCT
      cr.hkey_currencyrate
    , cr.load_dtm
    , NULL
    , cr.record_source
    , cr.currencyratedate
    , cr.averagerate
    , cr.endofdayrate
FROM
                advworks_staging.currencyrate_{{ts_nodash}} cr
LEFT OUTER JOIN dv_raw.sat_currencyrate sat ON (
                sat.hkey_currencyrate = cr.hkey_currencyrate
            AND sat.load_end_dtm IS NULL)
WHERE
   COALESCE(cr.currencyratedate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET')) != COALESCE(sat.currencyratedate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET'))
OR COALESCE(cr.averagerate, '') != COALESCE(sat.averagerate, '')
OR COALESCE(cr.endofdayrate, '') != COALESCE(sat.endofdayrate, '')
