CREATE TABLE IF NOT EXISTS dv_raw.link_staff_store (
      hkey_staff_store STRING
    , hkey_staff       STRING
    , hkey_store       STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP)
STORED AS ORC;
