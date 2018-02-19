CREATE TABLE IF NOT EXISTS dv_raw.sat_person (
      hkey_person     STRING
    , load_dtm        TIMESTAMP
    , load_end_dtm    TIMESTAMP
    , record_source   STRING
    , persontype      STRING
    , namestyle       STRING
    , title           STRING
    , firstname       STRING
    , middlename      STRING
    , lastname        STRING
    , suffix          STRING
    , emailpromotion  INT
)
STORED AS ORC;
