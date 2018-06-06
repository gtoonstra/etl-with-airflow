CREATE TABLE IF NOT EXISTS dv_raw.hub_address (
      hkey_address    STRING
    , record_source   STRING
    , load_dtm        TIMESTAMP
    , address         STRING
    , postal_code     STRING)
STORED AS ORC;
