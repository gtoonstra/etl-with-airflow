DROP TABLE dv_star.dim_order;

CREATE TABLE dv_star.dim_order AS
SELECT
          hub.hkey_salesorder
        , hub.salesorderid
        , sat.revisionnumber
        , sat.orderdate
        , sat.duedate
        , sat.shipdate
        , sat.status
        , sat.onlineorderflag
        , sat.purchaseordernumber
        , sat.accountnumber
        , sat.creditcardapprovalcode
        , sat.subtotal
        , sat.taxamt
        , sat.freight
        , sat.totaldue
FROM
            dv_raw.sat_salesorder sat
INNER JOIN  dv_raw.hub_salesorder hub ON hub.hkey_salesorder = sat.hkey_salesorder
INNER JOIN  dv_raw.link_salesorderreason solink ON solink.hkey_salesorder = sat.hkey_salesorder
INNER JOIN  dv_raw.sat_salesreason satr ON solink.hkey_salesreason = satr.hkey_salesreason
WHERE
        sat.load_end_dtm IS NULL
AND     satr.load_end_dtm IS NULL
