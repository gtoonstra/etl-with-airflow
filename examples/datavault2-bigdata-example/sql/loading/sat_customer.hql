INSERT INTO TABLE dv_raw.sat_customer
SELECT DISTINCT
      a.hkey_customer
    , a.load_dtm
    , a.record_source
    , active
    , activebool
    , create_date
    , first_name
    , last_name
    , last_update
FROM
                advworks_staging.address_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_customer sat ON (
                sat.hkey_customer = a.hkey_customer
         AND    sat.load_dtm = a.load_dtm
WHERE
    sat.hkey_customer IS NULL
