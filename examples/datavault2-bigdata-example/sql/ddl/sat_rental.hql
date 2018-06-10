CREATE TABLE IF NOT EXISTS dv_raw.sat_rental (
      hkey_rental     STRING
    , load_dtm        TIMESTAMP
    , record_source   STRING    
    , return_date     TIMESTAMP
    , last_update     TIMESTAMP)
STORED AS ORC;
