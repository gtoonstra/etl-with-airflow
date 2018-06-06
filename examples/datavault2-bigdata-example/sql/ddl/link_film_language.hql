CREATE TABLE IF NOT EXISTS dv_raw.link_film_language (
      hkey_film_language STRING
    , hkey_film          STRING
    , hkey_language      STRING
    , record_source      STRING
    , load_dtm           TIMESTAMP)
STORED AS ORC;
