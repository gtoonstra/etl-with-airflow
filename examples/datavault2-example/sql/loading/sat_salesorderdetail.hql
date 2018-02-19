INSERT INTO TABLE dv_raw.sat_salesorderdetail
SELECT DISTINCT
      so.hkey_salesorderdetail
    , so.load_dtm
    , NULL
    , so.record_source
    , so.carriertrackingnumber
    , so.orderqty
    , so.unitprice
    , so.unitpricediscount
FROM
                advworks_staging.salesorderdetail_{{ts_nodash}} so
LEFT OUTER JOIN dv_raw.sat_salesorderdetail sat ON (
                sat.hkey_salesorderdetail = so.hkey_salesorderdetail
            AND sat.load_end_dtm IS NULL)
WHERE
    COALESCE(so.carriertrackingnumber, '') != COALESCE(sat.carriertrackingnumber, '')
AND COALESCE(so.orderqty, '') != COALESCE(sat.orderqty, '')
AND COALESCE(so.unitprice, '') != COALESCE(sat.unitprice, '')
AND COALESCE(so.unitpricediscount, '') != COALESCE(sat.unitpricediscount, '')
