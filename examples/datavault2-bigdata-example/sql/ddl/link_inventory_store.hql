CREATE TABLE IF NOT EXISTS dv_raw.link_inventory_store (
      hkey_inventory_film STRING
    , hkey_inventory      STRING
    , hkey_store          STRING
    , record_source       STRING
    , load_dtm            TIMESTAMP)
STORED AS ORC;
