INSERT INTO TABLE dv_raw.link_film_language
SELECT DISTINCT
    fl.dv__bk as hkey_film_language,
    fl.film_bk as hkey_film,
    fl.language_bk as hkey_language,
    fl.dv__rec_source as record_source,
    from_unixtime(unix_timestamp(fl.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
FROM
    staging_dvdrentals.film_language_{{ts_nodash}} fl
WHERE
    NOT EXISTS (
        SELECT 
                lfl.hkey_film_language
        FROM    dv_raw.link_film_language lfl
        WHERE 
                lfl.hkey_film = fl.film_bk
        AND     lfl.hkey_language = fl.language_bk
    )
