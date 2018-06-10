INSERT INTO TABLE dv_raw.sat_staff
SELECT DISTINCT
      a.hkey_staff
    , a.load_dtm
    , a.record_source
    , active
    , email
    , last_update
FROM
                advworks_staging.address_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_staff sat ON (
                sat.hkey_staff = a.hkey_staff
         AND    sat.load_dtm = a.load_dtm
WHERE
    sat.hkey_staff IS NULL
