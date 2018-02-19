CREATE TABLE IF NOT EXISTS dv_raw.sat_product (
      hkey_product          STRING
    , load_dtm              TIMESTAMP
    , load_end_dtm          TIMESTAMP
    , record_source         STRING
    , productid             INT
    , name                  STRING
    , makeflag              INT
    , finishedgoodsflag     INT
    , color                 STRING
    , safetystocklevel      INT
    , reorderpoint          INT
    , standardcost          FLOAT
    , listprice             FLOAT
    , size                  STRING
    , weight                FLOAT
    , daystomanufacture     INT
    , productline           STRING
    , class                 STRING
    , style                 STRING
    , productmodelid        INT
    , sellstartdate         TIMESTAMP
    , sellenddate           TIMESTAMP
    , discontinueddate      TIMESTAMP
)
STORED AS ORC;
