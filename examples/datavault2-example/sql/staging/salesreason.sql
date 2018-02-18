SELECT
      sr.salesreasonid
    , sr.name
    , sr.reasontype
    , LTRIM(RTRIM(COALESCE(sr.name, ''))) as hkey_salesreason
FROM
    sales.salesreason sr
