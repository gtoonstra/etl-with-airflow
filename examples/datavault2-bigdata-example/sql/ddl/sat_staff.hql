CREATE TABLE IF NOT EXISTS dv_raw.sat_staff (
      hkey_staff      STRING
    , load_dtm        TIMESTAMP
    , record_source   STRING    
    , active          STRING
    , email           STRING
    , last_update     TIMESTAMP)
STORED AS ORC;
