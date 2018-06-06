CREATE TABLE IF NOT EXISTS dv_raw.link_rental (
      hkey_rental      STRING
    , hkey_film        STRING
    , hkey_store       STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP)
STORED AS ORC;
