CREATE TABLE IF NOT EXISTS dv_raw.hub_shipmethod (
      hkey_shipmethod    STRING
    , record_source      STRING
    , load_dtm           TIMESTAMP
    , name               STRING)
STORED AS ORC;
