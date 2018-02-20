CREATE TABLE dv_temp.{{params.hive_table}}_temp AS 
SELECT
      a.hkey_salesorderdetail
    , a.load_dtm
    , LEAD(a.load_dtm) OVER (PARTITION BY a.hkey_salesorderdetail ORDER BY a.load_dtm ASC) as load_end_dtm
    , a.record_source
    , a.carriertrackingnumber
    , a.orderqty
    , a.unitprice
    , a.unitpricediscount
FROM
    dv_raw.{{params.hive_table}} a;
