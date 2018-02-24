INSERT INTO TABLE dv_raw.link_salesorder_address
SELECT DISTINCT
    a.hkey_salesorder_address,
    a.hkey_salesorder,
    a.hkey_address_billtoaddressid,
    a.hkey_address_shiptoaddressid,
    a.record_source,
    a.load_dtm
FROM
           advworks_staging.salesorderheader_{{ts_nodash}} a
WHERE
    NOT EXISTS (
        SELECT 
                l.hkey_salesorder_address
        FROM    dv_raw.link_salesorder_address l
        WHERE 
                l.hkey_address_billtoaddressid = a.hkey_address_billtoaddressid
        AND     l.hkey_address_shiptoaddressid = a.hkey_address_shiptoaddressid
    )
