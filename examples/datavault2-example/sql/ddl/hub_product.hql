CREATE TABLE IF NOT EXISTS dv_raw.hub_product (
      hkey_product     STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP
    , productnumber    STRING)
STORED AS ORC;
