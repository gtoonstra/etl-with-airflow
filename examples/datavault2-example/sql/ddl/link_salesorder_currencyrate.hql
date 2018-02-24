CREATE TABLE IF NOT EXISTS dv_raw.link_salesorder_currencyrate (
      hkey_currencyrate              STRING
    , hkey_currency_fromcurrencycode STRING
    , hkey_currency_tocurrencycode   STRING      
    , record_source                  STRING
    , load_dtm                       TIMESTAMP)
STORED AS ORC;
