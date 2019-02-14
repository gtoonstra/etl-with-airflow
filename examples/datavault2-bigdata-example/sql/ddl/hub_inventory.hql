CREATE TABLE IF NOT EXISTS dv_raw.hub_inventory (
      hkey_inventory   STRING
    , record_source    STRING
    , load_dtm         TIMESTAMP
    , inventory_id     INT)
STORED AS PARQUET;
