CREATE TABLE IF NOT EXISTS dv_raw.sat_customer (
      hkey_customer   STRING
    , load_dtm        TIMESTAMP
    , record_source   STRING    
    , active          INT
    , activebool      STRING
    , create_date     TIMESTAMP
    , first_name      STRING
    , last_name       STRING
    , last_update     TIMESTAMP)
STORED AS ORC;
