CREATE TABLE IF NOT EXISTS dv_raw.hub_currency (
      hkey_currency   STRING
    , record_source   STRING
    , load_dtm        TIMESTAMP
    , currencycode    STRING)
STORED AS ORC;
