INSERT INTO TABLE dv_raw.link_rental
SELECT DISTINCT
    upper(md5(concat(fc.customer_bk, fc.inventory_bk))) as hkey_rental,
    fc.record_source,
    fc.load_dtm,
    fc.customer_bk,
    fc.inventory_bk
FROM
    staging_dvdrentals.rental_{{ts_nodash}} r
WHERE
    NOT EXISTS (
        SELECT 
                lr.hkey_rental
        FROM    dv_raw.link_rental lr
        WHERE 
                lr.hkey_customer = r.customer_bk
        AND     lr.hkey_inventory = r.inventory_bk
    )
