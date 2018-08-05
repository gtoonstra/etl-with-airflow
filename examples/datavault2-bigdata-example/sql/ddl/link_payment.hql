CREATE TABLE IF NOT EXISTS dv_raw.link_payment (
      hkey_payment     STRING
    , hkey_customer    STRING
    , hkey_staff       STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP)
STORED AS ORC;
