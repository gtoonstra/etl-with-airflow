CREATE TABLE IF NOT EXISTS dv_raw.sat_stateprovince (
      hkey_shipmethod           STRING
    , load_dtm                  TIMESTAMP
    , load_end_dtm              TIMESTAMP
    , record_source             STRING
    , stateprovinceid           INT
    , isonlystateprovinceflag   STRING
    , name                      STRING
)
STORED AS ORC;
