INSERT INTO TABLE dv_raw.link_rental_inventory
SELECT DISTINCT
    r.dv__bk as hkey_rental_inventory,
    r.rental_bk as hkey_rental,    
    r.inventory_bk as hkey_inventory,
    r.dv__rec_source as record_source,
    from_unixtime(unix_timestamp(r.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
FROM
    staging_dvdrentals.rental_inventory_{{ts_nodash}} r
WHERE
    NOT EXISTS (
        SELECT 
                lr.hkey_rental_inventory
        FROM    dv_raw.link_rental_inventory lr
        WHERE 
                lr.hkey_rental = r.rental_bk
        AND     lr.hkey_inventory = r.inventory_bk
    )
