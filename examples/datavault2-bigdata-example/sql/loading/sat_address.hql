INSERT INTO TABLE dv_raw.sat_address
SELECT DISTINCT
      a.hkey_address
    , a.load_dtm
    , a.record_source
    , address2
    , city
    , country
    , district
    , phone
    , last_update
FROM
                advworks_staging.address_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_address sat ON (
                sat.hkey_address = a.hkey_address
         AND    sat.load_dtm = a.load_dtm
WHERE
    sat.hkey_address IS NULL
