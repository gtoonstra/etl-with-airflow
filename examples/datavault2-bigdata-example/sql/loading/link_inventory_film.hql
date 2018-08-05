INSERT INTO TABLE dv_raw.link_inventory_film
SELECT DISTINCT
    fc.dv__bk as hkey_inventory_film,
    fc.inventory_bk as hkey_inventory,
    fc.film_bk as hkey_film,
    fc.dv__rec_source as record_source,
    fc.dv__load_dtm as load_dtm
FROM
    staging_dvdrentals.inventory_film_{{ts_nodash}} fc
WHERE
    NOT EXISTS (
        SELECT 
                lif.hkey_inventory_film
        FROM    dv_raw.link_inventory_film lif
        WHERE 
                lif.hkey_inventory = fc.inventory_bk
        AND     lif.hkey_film = fc.film_bk
    )
