CREATE TABLE IF NOT EXISTS dv_raw.hub_stateprovince (
      hkey_stateprovince   STRING
    , record_source        STRING
    , load_dtm             TIMESTAMP
    , stateprovincecode    STRING
    , countryregioncode    STRING)
STORED AS ORC;
