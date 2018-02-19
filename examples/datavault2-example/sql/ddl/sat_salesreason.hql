CREATE TABLE IF NOT EXISTS dv_raw.sat_salesreason (
      hkey_salesreason     STRING
    , load_dtm             TIMESTAMP
    , load_end_dtm         TIMESTAMP
    , record_source        STRING
    , name                 STRING
    , reasontype           STRING
)
STORED AS ORC;
