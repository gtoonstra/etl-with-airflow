INSERT INTO TABLE dv_raw.hub_person
SELECT DISTINCT
    p.hkey_person,
    p.record_source,
    p.load_dtm,
    p.businessentityid
FROM
    advworks_staging.person_{{ts_nodash}} p
WHERE
    p.businessentityid NOT IN (
        SELECT hub.businessentityid FROM dv_raw.hub_person hub
    )
