INSERT INTO TABLE dv_raw.link_film_actor
SELECT DISTINCT
    upper(md5(concat(ca.hkey_film, ca.hkey_actor))) as hkey_film_actor,
    fa.hkey_film,
    fa.hkey_actor,
    fa.record_source,
    fa.load_dtm
FROM
    staging_dvdrentals.link_film_actor_{{ts_nodash}} fa
WHERE
    NOT EXISTS (
        SELECT 
                lca.hkey_film_actor
        FROM    dv_raw.link_film_actor lca
        WHERE 
                lca.hkey_film = ca.hkey_film
        AND     lca.hkey_actor = ca.hkey_actor
    )
