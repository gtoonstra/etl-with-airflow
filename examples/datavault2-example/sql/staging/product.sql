SELECT
      p.productid
    , p.name
    , p.productnumber
    , p.makeflag
    , p.finishedgoodsflag
    , p.color
    , p.safetystocklevel
    , p.reorderpoint
    , p.standardcost
    , p.listprice
    , p.size
    , p.sizeunitmeasurecode
    , p.weightunitmeasurecode
    , p.weight
    , p.daystomanufacture
    , p.productline
    , p.class
    , p.style
    , p.productsubcategoryid
    , p.productmodelid
    , p.sellstartdate
    , p.sellenddate
    , p.discontinueddate
    , LTRIM(RTRIM(COALESCE(CAST(p.productnumber as varchar), ''))) as hkey_product
    , LTRIM(RTRIM(COALESCE(CAST(p.sizeunitmeasurecode as varchar), ''))) as hkey_unitmeasure_sizeunitmeasurecode
    , LTRIM(RTRIM(COALESCE(CAST(p.weightunitmeasurecode as varchar), ''))) as hkey_unitmeasure_weightunitmeasurecode
    , LTRIM(RTRIM(COALESCE(CAST(pc.name as varchar), ''))) as hkey_productsubcategory
FROM
           production.product p
LEFT JOIN  production.productsubcategory pc ON p.productsubcategoryid = pc.productsubcategoryid
