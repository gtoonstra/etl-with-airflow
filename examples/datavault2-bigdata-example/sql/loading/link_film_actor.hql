INSERT INTO TABLE dv_raw.link_film_actor
SELECT DISTINCT
      Md5(CONCAT()) as hkey_film_actor
    , b.hkey_film as hkey_film
, c.hkey_actor as hkey_actor
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
FROM
    staging_dvdrentals.film_actor_{{ts_nodash}} a
  INNER JOIN dv_raw.hub_film b ON b.film_id = a.film_id
  INNER JOIN dv_raw.hub_actor c ON c.actor_id = a.actor_id
WHERE
    NOT EXISTS (
        SELECT 
                link.hkey_film_actor
        FROM    dv_raw.link_film_actor link
        WHERE 
                    link.hkey_film = b.hkey_film
AND     link.hkey_actor = c.hkey_actor

    )
