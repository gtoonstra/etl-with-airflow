CREATE TABLE IF NOT EXISTS dv_raw.sat_inventory (
      hkey_inventory STRING
    , load_dtm       TIMESTAMP
    , record_source  STRING
    , last_update    TIMESTAMP)
STORED AS ORC;
