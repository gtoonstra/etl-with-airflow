CREATE TABLE IF NOT EXISTS dv_raw.hub_language (
      hkey_language   STRING
    , record_source   STRING
    , load_dtm        TIMESTAMP
    , language_id     INT
    , name            STRING)
STORED AS PARQUET;
