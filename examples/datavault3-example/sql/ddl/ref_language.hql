CREATE TABLE IF NOT EXISTS dv_raw.ref_language (
      name            STRING
    , record_source   STRING
    , load_dtm        TIMESTAMP
    , load_end_dtm    TIMESTAMP)
STORED AS ORC;
