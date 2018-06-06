CREATE TABLE IF NOT EXISTS dv_raw.link_staff_address (
      hkey_staff_address STRING
    , hkey_staff         STRING
    , hkey_address       STRING
    , record_source      STRING
    , load_dtm           TIMESTAMP)
STORED AS ORC;
