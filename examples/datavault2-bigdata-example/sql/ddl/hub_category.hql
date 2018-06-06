CREATE TABLE IF NOT EXISTS dv_raw.hub_category (
      hkey_category   STRING
    , record_source   STRING
    , load_dtm        TIMESTAMP
    , name            STRING)
STORED AS ORC;
