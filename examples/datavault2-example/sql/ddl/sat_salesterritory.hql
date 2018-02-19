CREATE TABLE IF NOT EXISTS dv_raw.sat_salesterritory (
      hkey_salesterritory  STRING
    , load_dtm             TIMESTAMP
    , load_end_dtm         TIMESTAMP
    , record_source        STRING
    , territoryid          INT
    , territory_group      STRING
    , salesytd             FLOAT
    , saleslastyear        FLOAT
    , costytd              FLOAT
    , costlastyear         FLOAT
)
STORED AS ORC;
