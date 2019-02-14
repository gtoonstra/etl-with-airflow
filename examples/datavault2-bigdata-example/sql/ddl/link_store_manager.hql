CREATE TABLE IF NOT EXISTS dv_raw.link_store_manager (
      hkey_store_manager STRING
    , hkey_store         STRING
    , hkey_staff         STRING
    , record_source      STRING
    , load_dtm           TIMESTAMP)
STORED AS PARQUET;
