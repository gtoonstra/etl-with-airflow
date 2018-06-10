INSERT INTO TABLE dv_raw.link_rental
SELECT DISTINCT
    upper(md5(concat(fc.hkey_film, fc.hkey_category))) as hkey_rental,
    fc.record_source,
    fc.load_dtm,
    fc.hkey_film,
    fc.hkey_store
FROM
    staging_dvdrentals.rental_{{ts_nodash}} r
WHERE
    NOT EXISTS (
        SELECT 
                lr.hkey_rental
        FROM    dv_raw.link_rental lr
        WHERE 
                lr.hkey_film = r.hkey_film
        AND     lr.hkey_store = r.hkey_store
    )
