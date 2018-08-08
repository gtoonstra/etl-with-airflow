INSERT INTO TABLE dv_raw.hub_inventory
SELECT DISTINCT
      a.dv__bk as hkey_inventory
    , a.dv__rec_source as rec_source
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
    , a.inventory_id
FROM
    staging_dvdrentals.inventory_{{ts_nodash}} a
WHERE
    (a.dv__status = 'NEW' OR a.dv__status = 'UPDATED')
AND
    NOT EXISTS (
        SELECT 
                hub.hkey_inventory
        FROM 
                dv_raw.hub_inventory hub
        WHERE
                hub.inventory_id = a.inventory_id
    )
