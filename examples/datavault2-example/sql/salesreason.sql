SELECT
      sr.salesreasonid
    , sr.name
    , sr.reasontype
    , LTRIM(RTRIM(COALESCE(sr.name, ''))) as hash_key_salesreason
FROM
    sales.salesreason sr
