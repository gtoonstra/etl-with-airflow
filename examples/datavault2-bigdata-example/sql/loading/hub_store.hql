INSERT INTO TABLE dv_raw.hub_store
SELECT DISTINCT
      a.dv__bk as hkey_store
    , a.dv__rec_source as rec_source
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
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
