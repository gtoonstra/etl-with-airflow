INSERT INTO TABLE dv_raw.hub_stateprovince
SELECT DISTINCT
    so.hkey_specialoffer,
    so.record_source,
    so.load_dtm,
    sp.stateprovinceid
FROM
    advworks_staging.stateprovince_{{ts_nodash}} so
WHERE
    so.stateprovinceid NOT IN (
        SELECT hub.stateprovinceid FROM dv_raw.hub_stateprovince hub
    )
