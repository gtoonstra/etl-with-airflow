CREATE TABLE IF NOT EXISTS dv_raw.hub_rental (
      hkey_rental     STRING
    , record_source   STRING
    , load_dtm        TIMESTAMP
    , rental_id       INT)
STORED AS PARQUET;
