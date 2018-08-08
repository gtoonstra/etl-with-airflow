INSERT INTO TABLE dv_raw.link_film_category
SELECT DISTINCT
    fc.dv__bk as hkey_film_category,
    fc.film_bk as hkey_film,
    fc.category_bk as hkey_category,    
    fc.dv__rec_source as record_source,
    from_unixtime(unix_timestamp(fc.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
FROM
    staging_dvdrentals.film_category_{{ts_nodash}} fc
WHERE
    NOT EXISTS (
        SELECT 
                lfc.hkey_film_category
        FROM    dv_raw.link_film_category lfc
        WHERE 
                lfc.hkey_film = fc.film_bk
        AND     lfc.hkey_category = fc.category_bk
    )
