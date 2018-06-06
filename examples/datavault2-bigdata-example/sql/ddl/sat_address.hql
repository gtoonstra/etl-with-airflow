CREATE TABLE IF NOT EXISTS dv_raw.sat_address (
      hkey_adress     STRING
    , load_dtm        TIMESTAMP
    , record_source   STRING    
    , address2        STRING
    , city            STRING
    , country         STRING
    , district        STRING
    , phone           STRING
    , last_update     TIMESTAMP)
STORED AS ORC;
