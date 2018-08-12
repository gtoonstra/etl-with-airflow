INSERT INTO TABLE dv_raw.sat_staff
SELECT DISTINCT
      a.dv__bk as hkey_staff
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
    , a.dv__rec_source as record_source
    , a.dv__cksum as checksum
    , a.email    
    , a.active
    , a.username
    , a.address
    , a.address2
    , a.district
    , a.city
    , a.postal_code
    , a.phone
    , a.country
FROM
                staging_dvdrentals.staff_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.vw_sat_staff sat
ON  sat.hkey_staff      = a.dv__bk
AND sat.load_end_dtm IS NULL
WHERE
    COALESCE(sat.checksum, '') != a.dv__cksum
