SELECT
      specialofferid
    , description
    , discountpct
    , type
    , category
    , startdate
    , enddate
    , minqty
    , maxqty
    , LTRIM(RTRIM(COALESCE(CAST(so.specialofferid as varchar), ''))) as hkey_specialoffer
FROM
    sales.specialoffer so
