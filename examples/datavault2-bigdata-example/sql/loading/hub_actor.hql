INSERT INTO TABLE dv_raw.hub_actor
SELECT DISTINCT
      Md5(CONCAT(LTRIM(RTRIM(COALESCE(CAST(a.first_name as string), ''))) , '-' ,
LTRIM(RTRIM(COALESCE(CAST(a.last_name as string), ''))))) as hkey_actor
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
      , a.actor_id
    , a.first_name
, a.last_name
FROM
    staging_dvdrentals.actor_{{ts_nodash}} a
WHERE
    NOT EXISTS (
        SELECT 
                hub.hkey_actor
        FROM 
                dv_raw.hub_actor hub
        WHERE
                    hub.first_name = a.first_name
AND     hub.last_name = a.last_name

    )
