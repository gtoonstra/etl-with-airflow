INSERT INTO TABLE dv_raw.sat_language
SELECT DISTINCT
      a.hkey_language
    , a.load_dtm
    , a.record_source
    , a.last_update
FROM
                advworks_staging.address_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_language sat ON (
                sat.hkey_language = a.hkey_language
         AND    sat.load_dtm = a.load_dtm
WHERE
    sat.hkey_language IS NULL
