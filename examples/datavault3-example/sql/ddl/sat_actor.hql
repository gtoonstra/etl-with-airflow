CREATE TABLE IF NOT EXISTS dv_raw.sat_actor (
      hkey_actor     STRING
    , load_dtm       TIMESTAMP
    , load_end_dtm   TIMESTAMP
    , record_source  STRING
    , first_name     STRING
    , last_name      STRING
)
STORED AS ORC;
