CREATE TABLE IF NOT EXISTS dv_raw.link_actor_film (
      hkey_actor       STRING
    , hkey_film        STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP)
STORED AS ORC;
