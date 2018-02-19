CREATE TABLE IF NOT EXISTS dv_raw.hub_salesorder (
      hkey_salesorder    STRING
    , record_source      STRING
    , load_dtm           TIMESTAMP
    , salesorderid       INT)
STORED AS ORC;
