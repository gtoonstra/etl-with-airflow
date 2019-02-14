INSERT INTO TABLE dv_raw.hub_film
SELECT DISTINCT
      Md5(CONCAT(LTRIM(RTRIM(COALESCE(CAST(a.title as string), ''))) , '-' ,
LTRIM(RTRIM(COALESCE(CAST(a.release_year as string), ''))))) as hkey_film
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
      , a.film_id
    , a.title
, a.release_year
FROM
    staging_dvdrentals.film_{{ts_nodash}} a
WHERE
    NOT EXISTS (
        SELECT 
                hub.hkey_film
        FROM 
                dv_raw.hub_film hub
        WHERE
                    hub.title = a.title
AND     hub.release_year = a.release_year

    )
