INSERT INTO TABLE dv_raw.link_film_language
SELECT DISTINCT
      Md5(CONCAT()) as hkey_film_language
    , b.hkey_film as hkey_film
, c.hkey_language as hkey_language
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
FROM
    staging_dvdrentals.film_{{ts_nodash}} a
  INNER JOIN dv_raw.hub_film b ON b.film_id = a.film_id
  INNER JOIN dv_raw.hub_language c ON c.language_id = a.language_id
WHERE
    NOT EXISTS (
        SELECT 
                link.hkey_film_language
        FROM    dv_raw.link_film_language link
        WHERE 
                    link.hkey_film = b.hkey_film
AND     link.hkey_language = c.hkey_language

    )
