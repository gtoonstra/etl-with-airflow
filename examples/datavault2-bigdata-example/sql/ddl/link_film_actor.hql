CREATE TABLE IF NOT EXISTS dv_raw.link_film_actor (
      hkey_film_actor  STRING
    , hkey_film        STRING      
    , hkey_actor       STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP)
STORED AS PARQUET;
