SELECT
      sod.salesorderid
    , sod.salesorderdetailid
    , sod.carriertrackingnumber
    , sod.orderqty
    , sod.productid
    , sod.specialofferid
    , sod.unitprice
    , sod.unitpricediscount
    , LTRIM(RTRIM(COALESCE(CAST(sod.salesorderdetailid as char(40)), ''))) as hash_key_salesorderdetail
    , LTRIM(RTRIM(COALESCE(CAST(sod.salesorderid as char(40)), ''))) as hash_key_salesorderheader
    , LTRIM(RTRIM(COALESCE(p.productnumber, ''))) as hash_key_product
    , LTRIM(RTRIM(COALESCE(CAST(sod.specialofferid as char(40)), ''))) as hash_key_specialoffer
FROM
            sales.salesorderdetail sod
INNER JOIN  production.product p ON sod.productid = p.productid 
