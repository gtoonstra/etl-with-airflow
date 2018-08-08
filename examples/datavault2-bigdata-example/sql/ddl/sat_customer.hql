CREATE TABLE IF NOT EXISTS dv_raw.sat_customer (
      hkey_customer   STRING
    , load_dtm        TIMESTAMP
    , record_source   STRING    
    , active          INT
    , activebool      STRING
    , create_date     DATE
    , first_name      STRING
    , last_name       STRING
    , address         STRING
    , address2        STRING
    , district        STRING
    , city            STRING
    , postal_code     STRING
    , phone           STRING
    , country         STRING
)
STORED AS ORC;
