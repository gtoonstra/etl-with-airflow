INSERT INTO TABLE dv_raw.hub_salesorder
SELECT DISTINCT
    soh.hkey_salesorder,
    soh.record_source,
    soh.load_dtm,
    soh.salesorderid
FROM
    advworks_staging.salesorderheader_{{ts_nodash}} soh
WHERE
    soh.salesorderid NOT IN (
        SELECT hub.salesorderid FROM dv_raw.hub_salesorder hub
    )
