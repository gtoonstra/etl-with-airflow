INSERT INTO TABLE dv_raw.link_inventory_film_store
SELECT DISTINCT
      Md5(CONCAT()) as hkey_inventory_film_store
    , b.hkey_inventory as hkey_inventory
, c.hkey_film as hkey_film
, d.hkey_store as hkey_store
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
FROM
    staging_dvdrentals.inventory_{{ts_nodash}} a
  INNER JOIN dv_raw.hub_inventory b ON b.inventory_id = a.inventory_id
  INNER JOIN dv_raw.hub_film c ON c.film_id = a.film_id
  INNER JOIN dv_raw.hub_store d ON d.store_id = a.store_id
WHERE
    NOT EXISTS (
        SELECT 
                link.hkey_inventory_film_store
        FROM    dv_raw.link_inventory_film_store link
        WHERE 
                    link.hkey_inventory = b.hkey_inventory
AND     link.hkey_film = c.hkey_film
AND     link.hkey_store = d.hkey_store

    )
