CREATE TABLE dv_temp.{{params.hive_table}}_temp AS 
SELECT
      a.hkey_person
    , a.load_dtm
    , LEAD(a.load_dtm) OVER (PARTITION BY a.hkey_person ORDER BY a.load_dtm ASC) as load_end_dtm
    , a.record_source
    , a.persontype
    , a.namestyle
    , a.title
    , a.firstname
    , a.middlename
    , a.lastname
    , a.suffix
    , a.emailpromotion
FROM
    dv_raw.{{params.hive_table}} a;
