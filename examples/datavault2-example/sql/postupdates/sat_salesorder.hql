CREATE TABLE dv_temp.{{params.hive_table}}_temp AS 
SELECT
      a.hkey_salesorder
    , a.load_dtm
    , LEAD(a.load_dtm) OVER (PARTITION BY a.hkey_salesorder ORDER BY a.load_dtm ASC) as load_end_dtm
    , a.record_source
    , a.revisionnumber
    , a.orderdate
    , a.duedate
    , a.shipdate
    , a.status
    , a.onlineorderflag
    , a.purchaseordernumber
    , a.accountnumber
    , a.creditcardapprovalcode
    , a.subtotal
    , a.taxamt
    , a.freight
    , a.totaldue
FROM
    dv_raw.{{params.hive_table}} a;
