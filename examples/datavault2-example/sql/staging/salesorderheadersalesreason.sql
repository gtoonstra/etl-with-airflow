SELECT
      sohsr.salesorderid
    , sohsr.salesreasonid
    , LTRIM(RTRIM(COALESCE(CAST(sohsr.salesorderid as varchar), ''))) as hash_key_salesorderheadersalesreason
FROM
            sales.salesorderheadersalesreason sohsr
