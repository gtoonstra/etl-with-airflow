CREATE TABLE IF NOT EXISTS dv_raw.link_rental_transaction (
      hkey_rental_transaction STRING
    , hkey_rental          STRING
    , hkey_customer        STRING
    , hkey_inventory       STRING
    , hkey_staff           STRING
    , record_source        STRING
    , load_dtm             TIMESTAMP)
STORED AS PARQUET;
