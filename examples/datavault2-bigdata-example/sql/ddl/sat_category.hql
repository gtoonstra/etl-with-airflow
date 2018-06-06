CREATE TABLE IF NOT EXISTS dv_raw.sat_category (
      hkey_category   STRING
    , load_dtm        TIMESTAMP
    , record_source   STRING    
    , last_update     TIMESTAMP)
STORED AS ORC;
