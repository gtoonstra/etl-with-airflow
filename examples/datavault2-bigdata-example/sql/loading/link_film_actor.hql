INSERT INTO TABLE dv_raw.link_film_actor
SELECT DISTINCT
    upper(md5(concat(fa.film_bk, fa.actor_bk))) as hkey_film_actor,
    fa.record_source,
    fa.load_dtm,
    fa.hkey_film,
    fa.hkey_actor
FROM
    staging_dvdrentals.film_actor_{{ts_nodash}} fa
WHERE
    NOT EXISTS (
        SELECT 
                lca.hkey_film_actor
        FROM    dv_raw.link_film_actor lca
        WHERE 
                lca.hkey_film = fa.film_bk
        AND     lca.hkey_actor = fa.actor_bk
    )
