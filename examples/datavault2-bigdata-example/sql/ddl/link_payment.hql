CREATE TABLE IF NOT EXISTS dv_raw.link_payment (
      hkey_payment     STRING
    , hkey_customer    STRING
    , hkey_staff       STRING
    , hkey_rental      STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP)
STORED AS PARQUET;
