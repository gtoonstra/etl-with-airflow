INSERT INTO TABLE dv_raw.link_film_language
SELECT DISTINCT
    upper(md5(concat(fc.hkey_film, fc.hkey_language))) as hkey_film_language,
    fc.hkey_film,
    fc.hkey_language,
    fc.record_source,
    fc.load_dtm
FROM
    staging_dvdrentals.link_film_language_{{ts_nodash}} fc
WHERE
    NOT EXISTS (
        SELECT 
                lca.hkey_film_language
        FROM    dv_raw.link_film_language lfc
        WHERE 
                lca.hkey_film = ca.hkey_film
        AND     lca.hkey_language = ca.hkey_language
    )
