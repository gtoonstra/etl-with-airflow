INSERT INTO TABLE dv_raw.sat_customer
SELECT DISTINCT
      a.dv__bk as hkey_customer
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
    , a.dv__rec_source as record_source
    , a.dv__cksum as checksum
    , a.active
    , a.activebool
    , cast(a.create_date as date)
    , a.first_name
    , a.last_name
    , a.address
    , a.address2
    , a.district
    , a.city
    , a.postal_code
    , a.phone
    , a.country
FROM
                staging_dvdrentals.customer_{{ts_nodash}} a
LEFT OUTER JOIN (
    SELECT  s.hkey_customer,
            s.load_dtm,
            s.checksum,
            row_number() OVER (PARTITION BY s.hkey_customer ORDER BY load_dtm DESC) AS most_recent_row
    FROM
            dv_raw.sat_customer s
) sat 
ON  sat.hkey_customer   = a.dv__bk
AND sat.most_recent_row = 1
WHERE
    COALESCE(sat.checksum, '') != a.dv__cksum
