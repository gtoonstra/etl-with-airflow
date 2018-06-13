CREATE TABLE IF NOT EXISTS dv_raw.sat_film (
      hkey_film        STRING
    , load_dtm         TIMESTAMP
    , record_source    STRING    
    , description      STRING
    , fulltext         STRING
    , last_update      TIMESTAMP
    , length           INT
    , rating           STRING
    , rental_duration  INT
    , rental_rate      DOUBLE
    , replacement_cost DOUBLE
    , special_features STRING)
STORED AS ORC;
