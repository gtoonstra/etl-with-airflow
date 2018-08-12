CREATE VIEW dv_raw.vw_sat_film AS
SELECT 
          hkey_film
        , load_dtm
        , LEAD(s.load_dtm, 1, '9999-12-31') OVER (PARTITION BY s.hkey_film ORDER BY s.load_dtm ASC) AS load_end_dtm
        , record_source
        , checksum
        , description
        , fulltext
        , length
        , rating
        , rental_duration
        , rental_rate
        , replacement_cost
        , special_features
FROM 
    dv_raw.sat_film s
