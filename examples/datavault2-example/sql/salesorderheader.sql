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
        , LTRIM(RTRIM(COALESCE(CAST(salesorderid as char(40)), ''))) as hash_key
        , LTRIM(RTRIM(COALESCE(CAST(customerid as char(40)), ''))) as hash_key_customer
        , LTRIM(RTRIM(COALESCE(CAST(sp.businessentityid as char(40)), ''))) as hash_key_salesperson
        , LTRIM(RTRIM(COALESCE(st.name, ''))) as hash_key_salesterritory
        , CONCAT(
            LTRIM(RTRIM(COALESCE(bta.addressline1, ''))), ';',
            LTRIM(RTRIM(COALESCE(bta.addressline2, ''))), ';',
            LTRIM(RTRIM(COALESCE(bta.postalcode, '')))
          ) as hash_key_billtoaddress
        , CONCAT(
            LTRIM(RTRIM(COALESCE(sta.addressline1, ''))), ';',
            LTRIM(RTRIM(COALESCE(sta.addressline2, ''))), ';',
            LTRIM(RTRIM(COALESCE(sta.postalcode, '')))
          ) as hash_key_shiptoaddress
        , LTRIM(RTRIM(COALESCE(sm.name, ''))) as hash_key_shipmethod
        , LTRIM(RTRIM(COALESCE(cc.cardnumber, ''))) as hash_key_creditcard
        , CONCAT(
            LTRIM(RTRIM(COALESCE(cr.fromcurrencycode, ''))), ';',
            LTRIM(RTRIM(COALESCE(cr.tocurrencycode, '')))
          ) as hash_key_currencyrate
FROM
                sales.salesorderheader soh
INNER JOIN      sales.salesperson sp ON soh.salespersonid = sp.businessentityid
INNER JOIN      sales.salesterritory st ON soh.territoryid = st.territoryid
INNER JOIN      person.address bta ON soh.billtoaddressid = bta.addressid
INNER JOIN      person.address sta ON soh.shiptoaddressid = sta.addressid 
INNER JOIN      purchasing.shipmethod sm ON soh.shipmethodid = sm.shipmethodid 
INNER JOIN      sales.creditcard cc ON soh.creditcardid = cc.creditcardid 
INNER JOIN      sales.currencyrate cr ON soh.currencyrateid = cr.currencyrateid
