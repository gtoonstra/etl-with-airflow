INSERT INTO TABLE dv_raw.sat_rental
SELECT DISTINCT
      a.dv__bk as hkey_rental
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
    , a.dv__rec_source as record_source
    , a.dv__cksum as checksum
    , cast(a.rental_date as date)
    , cast(a.return_date as date)
FROM
                staging_dvdrentals.rental_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.vw_sat_rental sat
ON  sat.hkey_rental     = a.dv__bk
AND sat.load_end_dtm IS NULL
WHERE   
    COALESCE(sat.checksum, '') != a.dv__cksum
