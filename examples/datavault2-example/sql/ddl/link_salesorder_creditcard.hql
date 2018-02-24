CREATE TABLE IF NOT EXISTS dv_raw.link_salesorder_creditcard (
      hkey_salesordercreditcard STRING
    , hkey_salesorder           STRING
    , hkey_creditcard           STRING
    , record_source             STRING
    , load_dtm                  TIMESTAMP)
STORED AS ORC;
