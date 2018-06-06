CREATE TABLE IF NOT EXISTS dv_raw.hub_store (
      hkey_actor      STRING
    , record_source   STRING
    , load_dtm        TIMESTAMP
    , store_id        INT)
STORED AS ORC;
