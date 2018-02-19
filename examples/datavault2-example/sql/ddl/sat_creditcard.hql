CREATE TABLE IF NOT EXISTS dv_raw.sat_creditcard (
      hkey_creditcard   STRING
    , load_dtm          TIMESTAMP
    , load_end_dtm      TIMESTAMP
    , record_source     STRING
    , creditcardid      INT
    , cardtype          STRING
    , expmonth          INT
    , expyear           INT
)
STORED AS ORC;
