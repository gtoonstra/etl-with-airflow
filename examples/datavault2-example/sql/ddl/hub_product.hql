CREATE TABLE IF NOT EXISTS hub_product (
      hkey_product     STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP
    , productnumber    STRING)
STORED AS ORC;
