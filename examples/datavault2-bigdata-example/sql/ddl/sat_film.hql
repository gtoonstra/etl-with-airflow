CREATE TABLE IF NOT EXISTS dv_raw.sat_film (
      hkey_film        STRING
    , load_dtm         TIMESTAMP
    , record_source    STRING
    , checksum         STRING
    , description      STRING
    , fulltext         STRING
    , length           INT
    , rating           STRING
    , rental_duration  INT
    , rental_rate      DOUBLE
    , replacement_cost DOUBLE
    , special_features STRING)
STORED AS PARQUET;
