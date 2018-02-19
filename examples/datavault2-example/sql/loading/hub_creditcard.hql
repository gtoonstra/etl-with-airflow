INSERT INTO TABLE dv_raw.hub_creditcard
SELECT DISTINCT
    cc.hkey_creditcard,
    cc.record_source,
    cc.load_dtm,
    cc.cardnumber
FROM
    advworks_staging.creditcard_{{ts_nodash}} cc
WHERE
    cc.cardnumber NOT IN (
        SELECT hub.cardnumber FROM dv_raw.hub_creditcard hub
    )
