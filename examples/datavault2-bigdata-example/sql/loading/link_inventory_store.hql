INSERT INTO TABLE dv_raw.link_inventory_store
SELECT DISTINCT
    is.dv__bk as hkey_inventory_store,
    is.inventory_bk as hkey_inventory,
    is.store_bk as hkey_store,
    is.dv__rec_source as record_source,
    is.dv__load_dtm as load_dtm
FROM
    staging_dvdrentals.inventory_store_{{ts_nodash}} is
WHERE
    NOT EXISTS (
        SELECT 
                lis.hkey_inventory_store
        FROM    dv_raw.link_inventory_store lis
        WHERE 
                lis.hkey_film = is.film_bk
        AND     lis.hkey_category = is.category_bk
    )
