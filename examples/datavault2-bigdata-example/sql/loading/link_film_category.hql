INSERT INTO TABLE dv_raw.link_film_category
SELECT DISTINCT
      Md5(CONCAT()) as hkey_film_category
    , b.hkey_film as hkey_film
, c.hkey_category as hkey_category
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
FROM
    staging_dvdrentals.film_category_{{ts_nodash}} a
  INNER JOIN dv_raw.hub_film b ON b.film_id = a.film_id
  INNER JOIN dv_raw.hub_category c ON c.category_id = a.category_id
WHERE
    NOT EXISTS (
        SELECT 
                link.hkey_film_category
        FROM    dv_raw.link_film_category link
        WHERE 
                    link.hkey_film = b.hkey_film
AND     link.hkey_category = c.hkey_category

    )
