CREATE TABLE IF NOT EXISTS dv_raw.link_address_stateprovince (
      hkey_address_stateprovince  STRING
    , hkey_stateprovince          STRING
    , hkey_address                STRING
    , record_source               STRING
    , load_dtm                    TIMESTAMP)
STORED AS ORC;
