CREATE TABLE IF NOT EXISTS dv_raw.hub_film (
      hkey_film        STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP
    , film_id          INT
    , release_year     INT
    , title            STRING)
STORED AS PARQUET;
