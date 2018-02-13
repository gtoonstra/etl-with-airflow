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
        , LTRIM(RTRIM(COALESCE(CAST(salesorderid as char(40)), ''))) as hash_input
FROM
        sales.salesorderheader
