CREATE TABLE IF NOT EXISTS dv_raw.sat_currency (
      hkey_currency     STRING
    , load_dtm          TIMESTAMP
    , load_end_dtm      TIMESTAMP
    , record_source     STRING
    , name              STRING
)
STORED AS ORC;
