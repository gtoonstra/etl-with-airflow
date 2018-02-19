CREATE TABLE IF NOT EXISTS dv_raw.sat_shipmethod (
      hkey_shipmethod  STRING
    , load_dtm         TIMESTAMP
    , load_end_dtm     TIMESTAMP
    , record_source    STRING
    , shipmethodid     INT
    , name             STRING
    , shipbase         DOUBLE
    , shiprate         DOUBLE
)
STORED AS ORC;
