CREATE TABLE IF NOT EXISTS link_salesorderdetail (
      hkey_salesorderdetail  STRING
    , hkey_salesorder        STRING
    , hkey_specialoffer      STRING
    , hkey_product           STRING
    , record_source          STRING
    , load_dtm               TIMESTAMP
    , salesorderdetailid     INT)
STORED AS ORC;
