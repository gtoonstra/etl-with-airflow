INSERT INTO TABLE dv_raw.sat_film
SELECT DISTINCT
      a.hkey_film
    , a.load_dtm
    , a.record_source
    , description
    , fulltext
    , last_update
    , length
    , rating
    , rental_duration
    , rental_rate
    , replacement_cost
    , special_features
FROM
                advworks_staging.address_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_film sat ON (
                sat.hkey_film = a.hkey_film
         AND    sat.load_dtm = a.load_dtm
WHERE
    sat.hkey_film IS NULL
