INSERT INTO TABLE dv_raw.sat_category
SELECT DISTINCT
      a.hkey_category
    , a.load_dtm
    , a.record_source
    , a.last_update
FROM
                advworks_staging.address_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_category sat ON (
                sat.hkey_category = a.hkey_category
         AND    sat.load_dtm = a.load_dtm
WHERE
    sat.hkey_category IS NULL
