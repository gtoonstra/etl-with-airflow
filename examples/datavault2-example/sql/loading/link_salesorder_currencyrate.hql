INSERT INTO TABLE dv_raw.link_salesorder_currencyrate
SELECT DISTINCT
    cr.hkey_salesorder_currencyrate,
    cr.hkey_salesorder,
    cr.hkey_currencyrate,
    cr.record_source,
    cr.load_dtm
FROM
           advworks_staging.salesorderheader_{{ts_nodash}} cr
WHERE
    soh.currencyrateid IS NOT NULL
AND NOT EXISTS (
        SELECT 
                l.hkey_salesorder_currencyrate
        FROM    dv_raw.link_salesorder_currencyrate l
        WHERE 
                l.hkey_salesorder = cr.hkey_salesorder
        AND     l.hkey_currencyrate = cr.hkey_currencyrate
    )
