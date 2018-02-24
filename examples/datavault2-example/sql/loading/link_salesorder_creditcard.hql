INSERT INTO TABLE dv_raw.link_salesorder_creditcard
SELECT DISTINCT
    soh.hkey_salesordercreditcard,
    soh.hkey_salesorder,
    soh.hkey_creditcard,
    soh.record_source,
    soh.load_dtm
FROM
           advworks_staging.salesorderheader_{{ts_nodash}} soh
WHERE
    NOT EXISTS (
        SELECT 
                l.hkey_salesordercreditcard
        FROM    dv_raw.link_salesorder_creditcard l
        WHERE 
                l.hkey_salesorder = soh.hkey_salesorder
        AND     l.hkey_creditcard = soh.hkey_creditcard
    )
