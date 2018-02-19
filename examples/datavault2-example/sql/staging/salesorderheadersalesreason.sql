SELECT
      sohsr.salesorderid
    , sohsr.salesreasonid
    , LTRIM(RTRIM(COALESCE(CAST(sohsr.salesorderid as varchar), ''))) as hkey_salesorder
    , LTRIM(RTRIM(COALESCE(CAST(sr.name as varchar), ''))) as hkey_salesreason
    , CONCAT(
          LTRIM(RTRIM(COALESCE(CAST(sohsr.salesorderid as varchar), ''))), ';'
        , LTRIM(RTRIM(COALESCE(CAST(sr.name as varchar), '')))
      ) as hkey_salesorderreason
FROM
            sales.salesorderheadersalesreason sohsr
INNER JOIN  sales.salesreason sr ON sohsr.salesreasonid = sr.salesreasonid
