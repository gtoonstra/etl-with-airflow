CREATE TABLE IF NOT EXISTS sat_salesorder (
      revisionnumber         INT
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
    , comment                STRING
    , hkey_salesorder        STRING
    , record_source          STRING
    , load_dtm               TIMESTAMP)
STORED AS ORC;
