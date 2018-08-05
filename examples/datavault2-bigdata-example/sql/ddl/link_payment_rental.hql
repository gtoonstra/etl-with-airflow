CREATE TABLE IF NOT EXISTS dv_raw.link_payment_rental (
      hkey_payment_rental  STRING
    , hkey_payment         STRING
    , hkey_rental          STRING
    , record_source        STRING
    , load_dtm             TIMESTAMP)
STORED AS ORC;
