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
        , LTRIM(RTRIM(COALESCE(CAST(soh.customerid as varchar), ''))) as hkey_customer
        , LTRIM(RTRIM(COALESCE(CAST(soh.salespersonid as varchar), ''))) as hkey_salesperson
        , LTRIM(RTRIM(COALESCE(CAST(st.name as varchar), ''))) as hkey_salesterritory
        , CONCAT(
              LTRIM(RTRIM(COALESCE(CAST(a1.postalcode as varchar), ''))), ';'
            , LTRIM(RTRIM(COALESCE(CAST(a1.addressline1 as varchar), ''))), ';'
            , LTRIM(RTRIM(COALESCE(CAST(a1.addressline2 as varchar), '')))
          ) as hkey_address_billtoaddressid
        , CONCAT(
              LTRIM(RTRIM(COALESCE(CAST(a2.postalcode as varchar), ''))), ';'
            , LTRIM(RTRIM(COALESCE(CAST(a2.addressline1 as varchar), ''))), ';'
            , LTRIM(RTRIM(COALESCE(CAST(a2.addressline2 as varchar), '')))
          ) as hkey_address_shiptoaddressid
        , LTRIM(RTRIM(COALESCE(CAST(sm.name as varchar), ''))) as hkey_shipmethod
        , LTRIM(RTRIM(COALESCE(CAST(cc.cardnumber as varchar), ''))) as hkey_creditcard
        , CONCAT(
              LTRIM(RTRIM(COALESCE(CAST(cr.currencyratedate as varchar), ''))), ';'
            , LTRIM(RTRIM(COALESCE(CAST(cr.fromcurrencycode as varchar), ''))), ';'
            , LTRIM(RTRIM(COALESCE(CAST(cr.tocurrencycode as varchar), '')))
          ) as hkey_currencyrate
FROM
            sales.salesorderheader soh
INNER JOIN  sales.salesterritory st ON soh.territoryid = st.territoryid
INNER JOIN  person.address a1 ON soh.billtoaddressid = a1.addressid
INNER JOIN  person.address a2 ON soh.shiptoaddressid = a2.addressid
INNER JOIN  purchasing.shipmethod sm ON soh.shipmethodid = sm.shipmethodid
INNER JOIN  sales.creditcard cc ON soh.creditcardid = cc.creditcardid
INNER JOIN  sales.currencyrate cr ON soh.currencyrateid = cr.currencyrateid
