SELECT
      sod.salesorderid
    , sod.salesorderdetailid
    , sod.carriertrackingnumber
    , sod.orderqty
    , sod.productid
    , sod.specialofferid
    , sod.unitprice
    , sod.unitpricediscount
    , LTRIM(RTRIM(COALESCE(CAST(sod.salesorderdetailid as varchar), ''))) as hkey_salesorderdetail
    , LTRIM(RTRIM(COALESCE(CAST(sod.salesorderid as varchar), ''))) as hkey_salesorder
    , LTRIM(RTRIM(COALESCE(CAST(so.specialofferid as varchar), ''))) as hkey_specialoffer
    , LTRIM(RTRIM(COALESCE(CAST(p.productnumber as varchar), ''))) as hkey_product
FROM
            sales.salesorderdetail sod
INNER JOIN  sales.specialoffer so ON sod.specialofferid = so.specialofferid
INNER JOIN  production.product p ON sod.productid = p.productid
