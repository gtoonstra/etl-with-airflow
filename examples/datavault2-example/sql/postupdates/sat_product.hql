CREATE TABLE dv_temp.{{params.hive_table}}_temp AS 
SELECT
      a.hkey_product
    , a.load_dtm
    , LEAD(a.load_dtm) OVER (PARTITION BY a.hkey_product ORDER BY a.load_dtm ASC) as load_end_dtm
    , a.record_source
    , a.productid
    , a.name
    , a.makeflag
    , a.finishedgoodsflag
    , a.color
    , a.safetystocklevel
    , a.reorderpoint
    , a.standardcost
    , a.listprice
    , a.size
    , a.weight
    , a.daystomanufacture
    , a.productline
    , a.class
    , a.style
    , a.productmodelid
    , a.sellstartdate
    , a.sellenddate
    , a.discontinueddate
FROM
    dv_raw.{{params.hive_table}} a;
