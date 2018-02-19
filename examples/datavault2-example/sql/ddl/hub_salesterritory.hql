CREATE TABLE IF NOT EXISTS dv_raw.hub_salesterritory (
      hkey_salesterritory  STRING
    , record_source        STRING
    , load_dtm             TIMESTAMP
    , name                 STRING)
STORED AS ORC;
