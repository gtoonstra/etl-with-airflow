CREATE TABLE IF NOT EXISTS dv_raw.sat_address (
      hkey_address      STRING
    , load_dtm          TIMESTAMP
    , load_end_dtm      TIMESTAMP
    , record_source     STRING
    , addressid         INT
    , city              STRING
    , spatiallocation   STRING
)
STORED AS ORC;
