CREATE TABLE IF NOT EXISTS sat_salesorderdetail (
      hkey_salesorderdetail  STRING
    , load_dtm               TIMESTAMP
    , load_end_dtm           TIMESTAMP
    , record_source          STRING
    , carriertrackingnumber  STRING
    , orderqty               INT
    , unitprice              DOUBLE
    , unitpricediscount      DOUBLE
)
STORED AS ORC;
