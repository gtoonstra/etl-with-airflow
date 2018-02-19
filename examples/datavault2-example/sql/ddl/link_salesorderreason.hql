CREATE TABLE IF NOT EXISTS dv_raw.link_salesorderreason (
      hkey_salesorderreason STRING
    , hkey_salesreason      STRING
    , hkey_salesorder       STRING
    , record_source         STRING
    , load_dtm              TIMESTAMP)
STORED AS ORC;
