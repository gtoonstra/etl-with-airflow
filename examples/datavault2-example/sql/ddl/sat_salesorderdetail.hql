CREATE TABLE IF NOT EXISTS sat_salesorderdetail (
      carriertrackingnumber  STRING
    , orderqty               INT
    , unitprice              DOUBLE
    , unitpricediscount      DOUBLE
    , hkey_salesorderdetail  STRING
    , record_source          STRING
    , load_dtm               TIMESTAMP)
STORED AS ORC;
