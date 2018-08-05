CREATE TABLE IF NOT EXISTS dv_raw.sat_staff (
      hkey_staff      STRING
    , load_dtm        TIMESTAMP
    , record_source   STRING    
    , email           STRING
    , active          STRING    
    , username        STRING
    , address         STRING
    , address2        STRING
    , district        STRING
    , city            STRING
    , postal_code     STRING
    , phone           STRING
    , country         STRING)
STORED AS ORC;
