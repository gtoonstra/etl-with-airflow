INSERT INTO TABLE dv_raw.sat_payment
SELECT DISTINCT
      a.dv__bk as hkey_payment
    , a.dv__load_dtm as load_dtm
    , a.dv__rec_source as record_source
    , a.amount
    , a.payment_date
FROM
                staging_dvdrentals.payment_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_payment sat ON
                sat.hkey_payment = a.dv__bk
         AND    sat.load_dtm = a.dv__load_dtm
WHERE
    sat.hkey_payment IS NULL
