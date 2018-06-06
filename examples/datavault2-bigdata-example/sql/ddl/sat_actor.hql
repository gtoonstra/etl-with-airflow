CREATE TABLE IF NOT EXISTS dv_raw.sat_actor (
      hkey_actor     STRING
    , load_dtm       TIMESTAMP
    , record_source  STRING
    , last_update    TIMESTAMP)
STORED AS ORC;
