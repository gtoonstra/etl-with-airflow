DROP TABLE dv_star.fact_orderdetail;

CREATE TABLE dv_star.fact_orderdetail AS
SELECT
          dp.hkey_product
        , do.hkey_salesorder
        , sat.carriertrackingnumber
        , sat.orderqty
        , sat.unitprice
        , sat.unitpricediscount
FROM
            dv_raw.sat_salesorderdetail sat
INNER JOIN  dv_raw.link_salesorderdetail link ON link.hkey_salesorderdetail = sat.hkey_salesorderdetail
INNER JOIN  dv_star.dim_product dp ON dp.hkey_product = link.hkey_product
INNER JOIN  dv_star.dim_order do ON do.hkey_salesorder = link.hkey_salesorder
