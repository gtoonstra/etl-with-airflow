INSERT INTO TABLE dv_raw.link_rental
SELECT DISTINCT
    upper(md5(concat(fc.hkey_film, fc.hkey_category))) as hkey_rental,
    fc.hkey_film,
    fc.hkey_store,
    fc.record_source,
    fc.load_dtm
FROM
    staging_dvdrentals.link_rental_{{ts_nodash}} r
WHERE
    NOT EXISTS (
        SELECT 
                lr.hkey_rental
        FROM    dv_raw.link_rental lr
        WHERE 
                lr.hkey_film = r.hkey_film
        AND     lr.hkey_store = r.hkey_store
    )
