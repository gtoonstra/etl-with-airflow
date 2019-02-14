CREATE TABLE IF NOT EXISTS dv_raw.hub_actor (
      hkey_actor      STRING
    , record_source   STRING
    , load_dtm        TIMESTAMP
    , actor_id        INT
    , first_name      STRING
    , last_name       STRING)
STORED AS PARQUET;
