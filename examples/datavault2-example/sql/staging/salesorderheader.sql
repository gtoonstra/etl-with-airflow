SELECT
          soh.salesorderid
        , soh.revisionnumber
        , soh.orderdate
        , soh.duedate
        , soh.shipdate
        , soh.status
        , soh.onlineorderflag
        , soh.purchaseordernumber
        , soh.accountnumber
        , soh.customerid
        , soh.salespersonid
        , soh.territoryid
        , soh.billtoaddressid
        , soh.shiptoaddressid
        , soh.shipmethodid
        , soh.creditcardid
        , soh.creditcardapprovalcode
        , soh.currencyrateid
        , soh.subtotal
        , soh.taxamt
        , soh.freight
        , soh.totaldue
        , LTRIM(RTRIM(COALESCE(CAST(soh.salesorderid as varchar), ''))) as hkey_salesorder
FROM
                sales.salesorderheader soh
