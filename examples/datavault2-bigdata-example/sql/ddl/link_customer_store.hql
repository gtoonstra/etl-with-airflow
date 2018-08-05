CREATE TABLE IF NOT EXISTS dv_raw.link_customer_store (
      hkey_customer_store STRING
    , hkey_customer       STRING
    , hkey_store          STRING
    , record_source       STRING
    , load_dtm            TIMESTAMP)
STORED AS ORC;
