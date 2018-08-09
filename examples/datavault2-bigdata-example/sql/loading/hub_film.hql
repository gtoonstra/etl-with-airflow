INSERT INTO TABLE dv_raw.hub_film
SELECT DISTINCT
      a.dv__bk as hkey_film
    , a.dv__rec_source as rec_source
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
    , a.release_year
    , a.title
FROM
    staging_dvdrentals.film_{{ts_nodash}} a
WHERE
    NOT EXISTS (
        SELECT 
                hub.hkey_film
        FROM 
                dv_raw.hub_film hub
        WHERE
                hub.release_year = a.release_year
        AND     hub.title = a.title
    )
