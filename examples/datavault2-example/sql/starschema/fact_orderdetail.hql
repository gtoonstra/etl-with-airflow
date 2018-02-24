DROP TABLE dv_star.fact_orderdetail;

CREATE TABLE dv_star.fact_orderdetail AS
SELECT
          dp.hkey_product
        , dso.hkey_salesorder
        , dba.hkey_address as hkey_bill_address
        , dsa.hkey_address as hkey_ship_address
        , sat.carriertrackingnumber
        , sat.orderqty
        , sat.unitprice
        , sat.unitpricediscount
FROM
            dv_raw.sat_salesorderdetail sat
INNER JOIN  dv_raw.link_salesorderdetail link ON link.hkey_salesorderdetail = sat.hkey_salesorderdetail
INNER JOIN  dv_star.dim_product dp ON dp.hkey_product = link.hkey_product
INNER JOIN  dv_star.dim_salesorder dso ON dso.hkey_salesorder = link.hkey_salesorder
INNER JOIN  dv_raw.link_salesorder_address soa ON soa.hkey_salesorder = link.hkey_salesorder
INNER JOIN  dv_star.dim_address dba ON dba.hkey_address = soa.hkey_address_billtoaddressid
INNER JOIN  dv_star.dim_address dsa ON dsa.hkey_address = soa.hkey_address_shiptoaddressid
