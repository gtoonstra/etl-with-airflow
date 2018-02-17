SELECT
      sod.salesorderid
    , sod.salesorderdetailid
    , sod.carriertrackingnumber
    , sod.orderqty
    , sod.productid
    , sod.specialofferid
    , sod.unitprice
    , sod.unitpricediscount
    , LTRIM(RTRIM(COALESCE(CAST(sod.salesorderdetailid as varchar), ''))) as hash_key_salesorderdetail
FROM
            sales.salesorderdetail sod
