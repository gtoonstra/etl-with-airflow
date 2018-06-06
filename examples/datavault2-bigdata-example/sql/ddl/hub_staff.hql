CREATE TABLE IF NOT EXISTS dv_raw.hub_staff (
      hkey_staff      STRING
    , record_source   STRING
    , load_dtm        TIMESTAMP
    , first_name      STRING
    , last_name       STRING)
STORED AS ORC;
