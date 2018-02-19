INSERT INTO TABLE dv_raw.link_salesorderdetail
SELECT DISTINCT
    sod.hkey_salesorderdetail,
    sod.hkey_salesorder,
    sod.hkey_specialoffer,
    sod.hkey_product,
    sod.record_source,
    sod.load_dtm
FROM
           advworks_staging.salesorderdetail_{{ts_nodash}} sod
WHERE
    NOT EXISTS (
        SELECT 
                l.hkey_salesorderdetail
        FROM    dv_raw.link_salesorderdetail l
        WHERE 
                l.hkey_salesorder = sod.hkey_salesorder
        AND     l.hkey_specialoffer = sod.hkey_specialoffer
        AND     l.hkey_product = sod.hkey_product
    )
