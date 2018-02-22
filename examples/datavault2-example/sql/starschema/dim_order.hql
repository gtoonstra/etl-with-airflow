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
WHERE
        sat.load_end_dtm IS NULL
