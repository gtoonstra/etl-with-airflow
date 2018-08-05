CREATE TABLE IF NOT EXISTS dv_raw.link_rental_inventory (
      hkey_rental_inventory STRING
    , hkey_rental           STRING
    , hkey_inventory        STRING
    , record_source         STRING
    , load_dtm              TIMESTAMP)
STORED AS ORC;
