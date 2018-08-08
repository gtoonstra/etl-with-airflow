INSERT INTO TABLE dv_raw.sat_rental
SELECT DISTINCT
      a.dv__bk as hkey_rental
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
    , a.dv__rec_source as record_source
    , cast(a.rental_date as date)
    , cast(a.return_date as date)
FROM
                staging_dvdrentals.rental_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_payment sat ON
                sat.hkey_payment = a.dv__bk
         AND    sat.load_dtm = a.dv__load_dtm
WHERE
    sat.hkey_payment IS NULL
