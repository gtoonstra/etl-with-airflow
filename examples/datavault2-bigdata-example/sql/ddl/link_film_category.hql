CREATE TABLE IF NOT EXISTS dv_raw.link_film_category (
      hkey_film_category STRING
    , hkey_film          STRING      
    , hkey_category      STRING
    , record_source      STRING
    , load_dtm           TIMESTAMP)
STORED AS ORC;
