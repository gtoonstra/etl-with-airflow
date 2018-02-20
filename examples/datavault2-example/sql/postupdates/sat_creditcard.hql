CREATE TABLE dv_temp.{{params.hive_table}}_temp AS 
SELECT
      a.hkey_creditcard
    , a.load_dtm
    , LEAD(a.load_dtm) OVER (PARTITION BY a.hkey_creditcard ORDER BY a.load_dtm ASC) as load_end_dtm
    , a.record_source
    , a.creditcardid
    , a.cardtype
    , a.expmonth
    , a.expyear
FROM
    dv_raw.{{params.hive_table}} a;
