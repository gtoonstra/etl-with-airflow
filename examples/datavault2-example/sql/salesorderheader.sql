SELECT
          salesorderid
        , revisionnumber
        , orderdate
        , duedate
        , shipdate
        , status
        , onlineorderflag
        , purchaseordernumber
        , accountnumber
        , customerid
        , salespersonid
        , territoryid
        , billtoaddressid
        , shiptoaddressid
        , shipmethodid
        , creditcardid
        , creditcardapprovalcode
        , currencyrateid
        , subtotal
        , taxamt
        , freight
        , totaldue
FROM
        sales.salesorderheader
