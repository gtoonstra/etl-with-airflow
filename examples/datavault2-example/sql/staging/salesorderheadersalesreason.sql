SELECT
      sohsr.salesorderid
    , sohsr.salesreasonid
    , LTRIM(RTRIM(COALESCE(CAST(sohsr.salesorderid as varchar), ''))) as hkey_salesorderheadersalesreason_salesorderid
    , LTRIM(RTRIM(COALESCE(CAST(sr.name as varchar), ''))) as hkey_salesreason
FROM
            sales.salesorderheadersalesreason sohsr
INNER JOIN  sales.salesreason sr ON sohsr.salesreasonid = sr.salesreasonid
