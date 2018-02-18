SELECT
      productid
    , name
    , productnumber
    , makeflag
    , finishedgoodsflag
    , color
    , safetystocklevel
    , reorderpoint
    , standardcost
    , listprice
    , size
    , sizeunitmeasurecode
    , weightunitmeasurecode
    , weight
    , daystomanufacture
    , productline
    , class
    , style
    , productsubcategoryid
    , productmodelid
    , sellstartdate
    , sellenddate
    , discontinueddate
    , LTRIM(RTRIM(COALESCE(CAST(p.productnumber as varchar), ''))) as hkey_product
FROM
    production.product p
