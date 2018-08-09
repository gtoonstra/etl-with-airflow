INSERT INTO TABLE dv_raw.hub_language
SELECT DISTINCT
      a.dv__bk as hkey_language
    , a.dv__rec_source as rec_source
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
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
