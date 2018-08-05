INSERT INTO TABLE dv_raw.sat_film
SELECT DISTINCT
      a.dv__bk as hkey_film
    , a.dv__load_dtm as load_dtm
    , a.dv__rec_source as record_source
    , a.description
    , a.fulltext
    , a.length
    , a.rating
    , a.rental_duration
    , a.rental_rate
    , a.replacement_cost
    , a.special_features
FROM
                staging_dvdrentals.film_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_film sat ON
                sat.hkey_film = a.dv__bk
         AND    sat.load_dtm = a.dv__load_dtm
WHERE
    sat.hkey_film IS NULL
