CREATE TABLE IF NOT EXISTS dv_raw.ref_countryregion (
      countryregioncode   STRING
    , record_source       STRING
    , load_dtm            TIMESTAMP
    , load_end_dtm        TIMESTAMP
    , name                STRING)
STORED AS ORC;
