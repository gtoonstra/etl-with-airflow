INSERT INTO TABLE dv_raw.sat_customer
SELECT DISTINCT
      a.dv__bk as hkey_customer
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
    , a.dv__rec_source as record_source
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
LEFT OUTER JOIN dv_raw.sat_customer sat ON
                sat.hkey_customer = a.dv__bk
         AND    sat.load_dtm = a.dv__load_dtm
WHERE
    sat.hkey_customer IS NULL
