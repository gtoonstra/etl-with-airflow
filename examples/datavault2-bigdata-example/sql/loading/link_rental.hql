INSERT INTO TABLE dv_raw.link_rental
SELECT DISTINCT
    r.rental_customer_bk as hkey_rental,
    r.dv__rec_source as record_source,
    r.dv__load_dtm as load_dtm,
    r.customer_bk,
    r.inventory_bk
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
