INSERT INTO TABLE dv_raw.link_film_actor
SELECT DISTINCT
    fa.dv__link_key as hkey_film_actor,
    fa.film_bk as hkey_film,
    fa.actor_bk as hkey_actor,
    fa.dv__rec_source as record_source,
    fa.dv__load_dtm as load_dtm
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
