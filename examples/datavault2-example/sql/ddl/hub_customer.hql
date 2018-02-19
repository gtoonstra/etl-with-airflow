CREATE TABLE IF NOT EXISTS dv_raw.hub_customer (
      hkey_customer    STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP
    , customerid       INT)
STORED AS ORC;
