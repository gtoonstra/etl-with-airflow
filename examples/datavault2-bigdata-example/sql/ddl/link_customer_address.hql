CREATE TABLE IF NOT EXISTS dv_raw.link_customer_address (
      hkey_customer_address  STRING
    , hkey_customer          STRING
    , hkey_address           STRING
    , record_source          STRING
    , load_dtm               TIMESTAMP)
STORED AS ORC;
