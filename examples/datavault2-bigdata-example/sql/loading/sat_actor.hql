INSERT INTO TABLE dv_raw.sat_actor
SELECT DISTINCT
      a.hkey_actor
    , a.load_dtm
    , a.record_source
    , a.last_update
FROM
                advworks_staging.address_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_actor sat ON (
                sat.hkey_actor = a.hkey_actor
         AND    sat.load_dtm = a.load_dtm
WHERE
    sat.hkey_actor IS NULL
