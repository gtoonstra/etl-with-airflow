SELECT
      sohsr.salesorderid
    , sohsr.salesreasonid
    , LTRIM(RTRIM(COALESCE(CAST(sohsr.salesorderid as char(40)), ''))) as hash_key_salesorderheader
    , LTRIM(RTRIM(COALESCE(CAST(sr.name as char(40)), ''))) as hash_key_salesreason
FROM
            sales.salesorderheadersalesreason sohsr
INNER JOIN  sales.salesreason sr ON sohsr.salesreasonid = sr.salesreasonid
