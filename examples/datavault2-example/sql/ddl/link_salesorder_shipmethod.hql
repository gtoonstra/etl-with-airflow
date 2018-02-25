CREATE TABLE IF NOT EXISTS dv_raw.link_salesorder_shipmethod (
      hkey_salesorder_shipmethod STRING
    , hkey_salesorder            STRING
    , hkey_shipmethod            STRING
    , record_source              STRING
    , load_dtm                   TIMESTAMP)
STORED AS ORC;
