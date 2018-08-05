CREATE TABLE IF NOT EXISTS dv_raw.link_inventory_film (
      hkey_inventory_film STRING
    , hkey_inventory      STRING
    , hkey_film           STRING
    , record_source       STRING
    , load_dtm            TIMESTAMP)
STORED AS ORC;
