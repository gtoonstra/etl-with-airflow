CREATE TABLE IF NOT EXISTS dv_raw.link_rental (
      hkey_rental      STRING
    , hkey_inventory   STRING
    , hkey_customer    STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP)
STORED AS ORC;
