CREATE TABLE IF NOT EXISTS dv_raw.sat_payment (
      hkey_payment    STRING
    , load_dtm        TIMESTAMP
    , record_source   STRING    
    , amount          DOUBLE
    , payment_date    TIMESTAMP)
STORED AS ORC;
