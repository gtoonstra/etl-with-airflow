SELECT
      sohsr.salesorderid
    , sohsr.salesreasonid
    , LTRIM(RTRIM(COALESCE(CAST(sohsr.salesorderid as varchar), ''))) as hkey_salesorderheadersalesreason
FROM
    sales.salesorderheadersalesreason sohsr
