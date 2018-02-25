INSERT INTO TABLE dv_raw.link_salesorder_shipmethod
SELECT DISTINCT
    soh.hkey_salesorder_shipmethod,
    soh.hkey_salesorder,
    soh.hkey_shipmethod,
    soh.record_source,
    soh.load_dtm
FROM
           advworks_staging.salesorderheader_{{ts_nodash}} soh
WHERE
    NOT EXISTS (
        SELECT 
                l.hkey_salesorder_shipmethod
        FROM    dv_raw.link_salesorder_shipmethod l
        WHERE 
                l.hkey_salesorder = soh.hkey_salesorder
        AND     l.hkey_shipmethod = soh.hkey_shipmethod
    )
