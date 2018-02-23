INSERT INTO TABLE dv_raw.sat_stateprovince
SELECT DISTINCT
      sp.hkey_stateprovince
    , sp.load_dtm
    , NULL
    , sp.record_source
    , sp.stateprovinceid
    , sp.isonlystateprovinceflag
    , sp.name
FROM
                advworks_staging.stateprovince_{{ts_nodash}} sp
LEFT OUTER JOIN dv_raw.sat_stateprovince sat ON (
                sat.hkey_stateprovince = sp.hkey_stateprovince
            AND sat.load_end_dtm IS NULL)
WHERE
    COALESCE(sp.stateprovinceid, '') != COALESCE(sat.stateprovinceid, '')
AND COALESCE(sp.isonlystateprovinceflag, '') != COALESCE(sat.isonlystateprovinceflag, '')
AND COALESCE(sp.name, '') != COALESCE(sat.name, '')
