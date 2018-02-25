DROP TABLE dv_star.fact_orderdetail;

CREATE TABLE dv_star.fact_orderdetail AS
SELECT
          dp.hkey_product
        , dso.hkey_salesorder
        , dba.hkey_dim_address as hkey_bill_address
        , dsa.hkey_dim_address as hkey_ship_address
        , dc.hkey_dim_currencyrate as hkey_currencyrate
        , st.hkey_salesterritory
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
INNER JOIN  dv_raw.link_salesorderterritory sot ON sot.hkey_salesorder = sot.hkey_salesorder
INNER JOIN  dv_star.dim_salesterritory st ON sot.hkey_salesterritory = st.hkey_salesterritory
INNER JOIN  dv_raw.link_salesorder_currencyrate socr ON socr.hkey_salesorder = link.hkey_salesorder
INNER JOIN  dv_star.dim_currency dc ON dc.hkey_currencyrate = socr.hkey_currencyrate
WHERE
            (dba.load_dtm <= dso.orderdate AND dba.load_end_dtm > dso.orderdate)
AND         (dsa.load_dtm <= dso.shipdate AND dsa.load_end_dtm > dso.shipdate)
AND         (dc.currencyratedate <= dso.orderdate AND dc.currencyratedate > dso.orderdate)
