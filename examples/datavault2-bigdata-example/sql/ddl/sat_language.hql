CREATE TABLE IF NOT EXISTS dv_raw.sat_language (
      hkey_language   STRING
    , load_dtm        TIMESTAMP
    , record_source   STRING    
    , last_update     TIMESTAMP)
STORED AS ORC;
