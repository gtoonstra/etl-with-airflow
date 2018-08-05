INSERT INTO TABLE dv_raw.link_inventory_store
SELECT DISTINCT
    s.dv__bk as hkey_inventory_store,
    s.inventory_bk as hkey_inventory,
    s.store_bk as hkey_store,
    s.dv__rec_source as record_source,
    s.dv__load_dtm as load_dtm
FROM
    staging_dvdrentals.inventory_store_{{ts_nodash}} s
WHERE
    NOT EXISTS (
        SELECT 
                lis.hkey_inventory_store
        FROM    dv_raw.link_inventory_store lis
        WHERE 
                lis.hkey_inventory = s.inventory_bk
        AND     lis.hkey_store = s.store_bk
    )
