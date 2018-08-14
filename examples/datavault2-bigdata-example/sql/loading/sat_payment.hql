INSERT INTO TABLE dv_raw.sat_payment
SELECT DISTINCT
      a.dv__bk as hkey_payment
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
    , a.dv__rec_source as record_source
    , a.dv__cksum as checksum
    , a.amount
    , cast(to_date(from_unixtime(unix_timestamp(a.payment_date, 'dd-MM-yyyy'))) as date) as payment_date
FROM
                staging_dvdrentals.payment_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.vw_sat_payment sat
ON  sat.hkey_payment    = a.dv__bk
AND sat.load_end_dtm    = unix_timestamp('9999-12-31', 'yyyy-MM-dd')
WHERE
    COALESCE(sat.checksum, '') != a.dv__cksum
