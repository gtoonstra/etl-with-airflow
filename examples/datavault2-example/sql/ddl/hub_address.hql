CREATE TABLE IF NOT EXISTS dv_raw.hub_address (
      hkey_address    STRING
    , record_source   STRING
    , load_dtm        TIMESTAMP
    , postalcode      STRING
    , addressline1    STRING
    , addressline2    STRING)
STORED AS ORC;
