INSERT INTO TABLE dv_raw.sat_store
SELECT DISTINCT
      a.hkey_store
    , a.load_dtm
    , a.record_source
    , a.last_update
FROM
                advworks_staging.address_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_store sat ON (
                sat.hkey_store = a.hkey_store
         AND    sat.load_dtm = a.load_dtm
WHERE
    sat.hkey_store IS NULL
