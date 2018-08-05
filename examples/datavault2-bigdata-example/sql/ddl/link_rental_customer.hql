CREATE TABLE IF NOT EXISTS dv_raw.link_rental_customer (
      hkey_rental_customer STRING
    , hkey_rental          STRING
    , hkey_customer        STRING
    , record_source        STRING
    , load_dtm             TIMESTAMP)
STORED AS ORC;
