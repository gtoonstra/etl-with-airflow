CREATE TABLE IF NOT EXISTS dv_raw.sat_rental (
      hkey_rental     STRING
    , load_dtm        TIMESTAMP
    , record_source   STRING   
    , rental_date     TIMESTAMP 
    , return_date     TIMESTAMP)
STORED AS ORC;
