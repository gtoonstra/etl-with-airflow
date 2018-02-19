INSERT INTO TABLE dv_raw.link_salesorderterritory
SELECT DISTINCT
    so.hkey_salesorderterritory,
    so.hkey_salesorder,
    so.hkey_salesterritory,
    so.record_source,
    so.load_dtm
FROM
           advworks_staging.salesorderheader_{{ts_nodash}} so
WHERE
    NOT EXISTS (
        SELECT 
                l.hkey_salesorderterritory
        FROM    dv_raw.link_salesorderterritory l
        WHERE 
                l.hkey_salesorder = so.hkey_salesorder
        AND     l.hkey_salesterritory = so.hkey_salesterritory
    )
