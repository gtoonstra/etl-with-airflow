CREATE TABLE IF NOT EXISTS dv_raw.hub_person (
      hkey_person      STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP
    , businessentityid INT)
STORED AS ORC;
