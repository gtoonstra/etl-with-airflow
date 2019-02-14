INSERT INTO TABLE dv_raw.hub_store
SELECT DISTINCT
      Md5(CONCAT(LTRIM(RTRIM(COALESCE(CAST(a.store_id as string), ''))))) as hkey_store
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
      
    , a.store_id
FROM
    staging_dvdrentals.store_{{ts_nodash}} a
WHERE
    NOT EXISTS (
        SELECT 
                hub.hkey_store
        FROM 
                dv_raw.hub_store hub
        WHERE
                    hub.store_id = a.store_id

    )
