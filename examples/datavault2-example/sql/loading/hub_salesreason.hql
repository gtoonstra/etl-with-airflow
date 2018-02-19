INSERT INTO TABLE dv_raw.hub_salesreason
SELECT DISTINCT
    sohsr.hkey_salesreason,
    sohsr.record_source,
    sohsr.load_dtm,
    sohsr.salesreasonid
FROM
    advworks_staging.salesorderheadersalesreason_{{ts_nodash}} sohsr
WHERE
    sohsr.salesreasonid NOT IN (
        SELECT hub.salesreasonid FROM dv_raw.hub_salesreason hub
    )
