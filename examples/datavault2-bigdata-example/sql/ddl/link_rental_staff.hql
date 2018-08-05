CREATE TABLE IF NOT EXISTS dv_raw.link_rental_staff (
      hkey_rental_staff STRING
    , hkey_rental       STRING
    , hkey_staff        STRING
    , record_source     STRING
    , load_dtm          TIMESTAMP)
STORED AS ORC;
