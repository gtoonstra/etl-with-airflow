INSERT INTO TABLE dv_raw.hub_category
SELECT DISTINCT
      Md5(CONCAT(LTRIM(RTRIM(COALESCE(CAST(a.name as string), ''))))) as hkey_category
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
      , a.category_id
    , a.name
FROM
    staging_dvdrentals.category_{{ts_nodash}} a
WHERE
    NOT EXISTS (
        SELECT 
                hub.hkey_category
        FROM 
                dv_raw.hub_category hub
        WHERE
                    hub.name = a.name

    )
