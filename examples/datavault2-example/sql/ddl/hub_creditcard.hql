CREATE TABLE IF NOT EXISTS dv_raw.hub_creditcard (
      hkey_creditcard STRING
    , record_source   STRING
    , load_dtm        TIMESTAMP
    , cardnumber      STRING)
STORED AS ORC;
