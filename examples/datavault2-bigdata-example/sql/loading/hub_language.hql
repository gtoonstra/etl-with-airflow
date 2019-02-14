INSERT INTO TABLE dv_raw.hub_language
SELECT DISTINCT
      Md5(CONCAT(LTRIM(RTRIM(COALESCE(CAST(a.name as string), ''))))) as hkey_language
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
      , a.language_id
    , a.name
FROM
    staging_dvdrentals.language_{{ts_nodash}} a
WHERE
    NOT EXISTS (
        SELECT 
                hub.hkey_language
        FROM 
                dv_raw.hub_language hub
        WHERE
                    hub.name = a.name

    )
