CREATE TABLE IF NOT EXISTS dv_raw.link_salesorder_address (
      hkey_salesorder_address      STRING
    , hkey_salesorder              STRING
    , hkey_address_billtoaddressid STRING
    , hkey_address_shiptoaddressid STRING
    , record_source                STRING
    , load_dtm                     TIMESTAMP)
STORED AS ORC;
