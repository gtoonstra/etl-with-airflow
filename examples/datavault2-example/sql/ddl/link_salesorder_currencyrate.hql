CREATE TABLE IF NOT EXISTS dv_raw.link_salesorder_currencyrate (
      hkey_salesorder_currencyrate   STRING
    , hkey_salesorder                STRING
    , hkey_currencyrate              STRING      
    , record_source                  STRING
    , load_dtm                       TIMESTAMP)
STORED AS ORC;
