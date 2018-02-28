SELECT
          fact.carriertrackingnumber as carriertrackingnumber
        , fact.orderqty as orderqty
        , fact.unitprice as unitprice
        , fact.unitpricediscount as unitpricediscount
        , dims.salesorderid as salesorderid
        , dims.revisionnumber as revisionnumber
        , dims.orderdate as orderdate
        , dims.duedate as duedate
        , dims.shipdate as shipdate
        , dims.status as status
        , dims.onlineorderflag as onlineorderflag
        , dims.purchaseordernumber as purchaseordernumber
        , dims.accountnumber as accountnumber
        , dims.creditcardapprovalcode as creditcardapprovalcode
        , dims.subtotal as subtotal
        , dims.taxamt as taxamt
        , dims.freight as freight
        , dims.totaldue as totaldue
        , dims.reasonname as reasonname
        , dims.reasontype as reasontype
        , dimab.postalcode as billing_postalcode
        , dimab.addressline1 as billing_addressline1
        , dimab.addressline2 as billing_adrressline2
        , dimab.city as billing_city
        , dimab.spatiallocation as billing_spatiallocation
        , dimab.stateprovincecode as billing_stateprovincecode
        , dimab.countryregioncode as billing_countryregioncode
        , dimab.countryregionname as billing_countryregionname
        , dimab.isonlystateprovinceflag as billing_isonlystateprovinceflag
        , dimab.name as billing_address_name
        , dimas.postalcode as shipping_postalcode
        , dimas.addressline1 as shipping_addressline1
        , dimas.addressline2 as shipping_adrressline2
        , dimas.city as shipping_city
        , dimas.spatiallocation as shipping_spatiallocation
        , dimas.stateprovincecode as shipping_stateprovincecode
        , dimas.countryregioncode as shipping_countryregioncode
        , dimas.countryregionname as shipping_countryregionname
        , dimas.isonlystateprovinceflag as shipping_isonlystateprovinceflag
        , dimas.name as shipping_address_name
        , dimc.currencycodea as currencycodea
        , dimc.currencynamea as currencynamea
        , dimc.currencycodeb as currencycodeb
        , dimc.currencynameb as currencynameb
        , dimc.currencyratedate as currencyratedate
        , dimc.averagerate as averagerate
        , dimc.endofdayrate as endofdayrate
        , dimp.productnumber as productnumber
        , dimp.name as product_name
        , dimp.makeflag as makeflag
        , dimp.finishedgoodsflag as finishedgoodsflag
        , dimp.color as color
        , dimp.safetystocklevel as safetystocklevel
        , dimp.reorderpoint as reorderpoint
        , dimp.standardcost as standardcost
        , dimp.listprice as listprice
        , dimp.size as product_size
        , dimp.weight as weight
        , dimp.daystomanufacture as daystomanufacture
        , dimp.productline as productline
        , dimp.class as product_class
        , dimp.style as product_style
        , dimp.productmodelid as productmodelid
        , dimp.sellstartdate as sellstartdate
        , dimp.sellenddate as sellenddate
        , dimp.discontinueddate as discontinueddate
        , dimst.territory_group as territory_group
        , dimst.salesytd as territory_salesytd
        , dimst.saleslastyear as territory_saleslastyear
        , dimst.costytd as territory_costytd
        , dimst.costlastyear as territory_costlastyear
FROM
            fact_orderdetail fact 
INNER JOIN  dim_address dimab ON fact.hkey_bill_address = dimab.hkey_dim_address
INNER JOIN  dim_address dimas ON fact.hkey_ship_address = dimas.hkey_dim_address
INNER JOIN  dim_salesorder dims ON fact.hkey_salesorder = dims.hkey_salesorder
INNER JOIN  dim_product dimp ON fact.hkey_product = dimp.hkey_product
LEFT JOIN  dim_currency dimc ON fact.hkey_currencyrate = dimc.hkey_dim_currencyrate
LEFT JOIN  dim_salesterritory dimst ON fact.hkey_salesterritory = dimst.hkey_salesterritory
