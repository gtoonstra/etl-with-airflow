INSERT INTO TABLE dv_raw.hub_inventory
SELECT DISTINCT
      Md5(CONCAT(LTRIM(RTRIM(COALESCE(CAST(a.inventory_id as string), ''))))) as hkey_inventory
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
      
    , a.inventory_id
FROM
    staging_dvdrentals.inventory_{{ts_nodash}} a
WHERE
    NOT EXISTS (
        SELECT 
                hub.hkey_inventory
        FROM 
                dv_raw.hub_inventory hub
        WHERE
                    hub.inventory_id = a.inventory_id

    )
