CREATE TABLE IF NOT EXISTS dv_raw.sat_store (
      hkey_store      STRING
    , load_dtm        TIMESTAMP
    , record_source   STRING    
    , last_update     TIMESTAMP)
STORED AS ORC;
