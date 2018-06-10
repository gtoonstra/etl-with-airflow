INSERT INTO TABLE dv_raw.link_film_category
SELECT DISTINCT
    upper(md5(concat(fc.film_bk, fc.category_bk))) as hkey_film_category,
    fc.record_source,
    fc.load_dtm,
    fc.film_bk as hkey_film,
    fc.category_bk as hkey_category
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
