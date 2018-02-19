CREATE TABLE IF NOT EXISTS sat_salesorder (
      hkey_salesorder        STRING
    , load_dtm               TIMESTAMP
    , load_end_dtm           TIMESTAMP
    , record_source          STRING
    , revisionnumber         INT
    , orderdate              TIMESTAMP
    , duedate                TIMESTAMP
    , shipdate               TIMESTAMP
    , status                 INT
    , onlineorderflag        STRING
    , purchaseordernumber    STRING
    , accountnumber          STRING
    , creditcardapprovalcode STRING
    , subtotal               DOUBLE
    , taxamt                 DOUBLE
    , freight                DOUBLE
    , totaldue               DOUBLE
)
STORED AS ORC;
