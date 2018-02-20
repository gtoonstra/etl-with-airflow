CREATE TABLE dv_temp.{{params.hive_table}}_temp AS 
SELECT
      a.hkey_salesterritory
    , a.load_dtm
    , LEAD(a.load_dtm) OVER (PARTITION BY a.hkey_salesterritory ORDER BY a.load_dtm ASC) as load_end_dtm
    , a.record_source
    , a.territoryid
    , a.territory_group
    , a.salesytd
    , a.saleslastyear
    , a.costytd
    , a.costlastyear
FROM
    dv_raw.{{params.hive_table}} a;
