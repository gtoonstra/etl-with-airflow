SELECT
      cc.creditcardid
    , cc.cardtype
    , cc.cardnumber
    , cc.expmonth
    , cc.expyear
    , LTRIM(RTRIM(COALESCE(CAST(cc.cardnumber as varchar), ''))) as hkey_creditcard
FROM
    sales.creditcard cc
