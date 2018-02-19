CREATE TABLE IF NOT EXISTS dv_raw.link_salesorderterritory (
      hkey_salesorderterritory STRING
    , hkey_salesorder          STRING
    , hkey_salesterritory      STRING
    , record_source            STRING
    , load_dtm                 TIMESTAMP)
STORED AS ORC;
