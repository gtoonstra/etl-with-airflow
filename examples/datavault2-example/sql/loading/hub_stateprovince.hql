INSERT INTO TABLE dv_raw.hub_stateprovince
SELECT DISTINCT
    sp.hkey_stateprovince,
    sp.record_source,
    sp.load_dtm,
    sp.stateprovincecode,
    sp.countryregioncode
FROM
    advworks_staging.stateprovince_{{ts_nodash}} sp
WHERE
    NOT EXISTS (
        SELECT 
                hub.hkey_stateprovince 
        FROM 
                dv_raw.hub_stateprovince hub
        WHERE
                hub.stateprovincecode = sp.stateprovincecode
        AND     hub.countryregioncode = sp.countryregioncode
    )
