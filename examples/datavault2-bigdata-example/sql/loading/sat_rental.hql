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
LEFT OUTER JOIN (
    SELECT  s.hkey_rental,
            s.load_dtm,
            s.checksum,
            row_number() OVER (PARTITION BY s.hkey_rental ORDER BY load_dtm DESC) AS most_recent_row
    FROM
            dv_raw.sat_rental s
) sat 
ON  sat.hkey_rental     = a.dv__bk
AND sat.most_recent_row = 1
WHERE   
    COALESCE(sat.checksum, '') != a.dv__cksum
