INSERT INTO TABLE dv_raw.link_salesorderdetail
SELECT DISTINCT
    sod.hkey_salesorderdetail,
    sor.hkey_salesorder,
    so.hkey_specialoffer,
    p.hkey_product,
    sod.record_source,
    sod.load_dtm,
    sod.salesorderdetailid
FROM
           advworks_staging.salesorderdetail_{{ts_nodash}} sod
INNER JOIN dv_raw.hub_salesorder sor ON sod.salesorderid = sor.salesorderid
INNER JOIN dv_raw.hub_specialoffer so ON sod.specialofferid = so.specialofferid
INNER JOIN dv_raw.hub_product p ON sod.productnumber = p.productnumber
WHERE
    NOT EXISTS (
        SELECT 
                l.hkey_salesorderdetail
        FROM    dv_raw.link_salesorderdetail l
        WHERE 
                l.hkey_salesorder = sor.hkey_salesorder
        AND     l.hkey_specialoffer = sor.hkey_specialoffer
        AND     l.hkey_product = sor.hkey_product
    )
