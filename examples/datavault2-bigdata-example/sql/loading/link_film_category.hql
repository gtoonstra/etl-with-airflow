INSERT INTO TABLE dv_raw.link_film_category
SELECT DISTINCT
    upper(md5(concat(fc.hkey_film, fc.hkey_category))) as hkey_film_category,
    fc.hkey_film,
    fc.hkey_category,
    fc.record_source,
    fc.load_dtm
FROM
    staging_dvdrentals.link_film_category_{{ts_nodash}} fc
WHERE
    NOT EXISTS (
        SELECT 
                lca.hkey_film_category
        FROM    dv_raw.link_film_category lfc
        WHERE 
                lca.hkey_film = ca.hkey_film
        AND     lca.hkey_category = ca.hkey_category
    )
