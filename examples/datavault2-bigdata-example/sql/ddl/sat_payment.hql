CREATE TABLE IF NOT EXISTS dv_raw.sat_payment (
      hkey_payment    STRING
    , load_dtm        TIMESTAMP
    , record_source   STRING
    , checksum        STRING    
    , amount          DOUBLE
    , payment_date    TIMESTAMP)
STORED AS PARQUET;
