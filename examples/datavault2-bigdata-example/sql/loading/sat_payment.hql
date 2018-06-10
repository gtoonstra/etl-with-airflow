INSERT INTO TABLE dv_raw.sat_payment
SELECT DISTINCT
      a.hkey_payment
    , a.load_dtm
    , a.record_source
    , amount
    , payment_date
FROM
                advworks_staging.address_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_payment sat ON (
                sat.hkey_payment = a.hkey_payment
         AND    sat.load_dtm = a.load_dtm
WHERE
    sat.hkey_payment IS NULL
