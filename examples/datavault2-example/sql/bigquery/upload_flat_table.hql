SELECT
          fact.carriertrackingnumber
        , fact.orderqty
        , fact.unitprice
        , fact.unitpricediscount
        , dims.salesorderid
        , dims.revisionnumber
        , dims.orderdate
        , dims.duedate
        , dims.shipdate
        , dims.status
        , dims.onlineorderflag
        , dims.purchaseordernumber
        , dims.accountnumber
        , dims.creditcardapprovalcode
        , dims.subtotal
        , dims.taxamt
        , dims.freight
        , dims.totaldue
        , dims.reasonname
        , dims.reasontype
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
        , dimc.currencycodea
        , dimc.currencynamea
        , dimc.currencycodeb
        , dimc.currencynameb
        , dimc.currencyratedate
        , dimc.averagerate
        , dimc.endofdayrate
        , dimp.productnumber
        , dimp.name as product_name
        , dimp.makeflag
        , dimp.finishedgoodsflag
        , dimp.color
        , dimp.safetystocklevel
        , dimp.reorderpoint
        , dimp.standardcost
        , dimp.listprice
        , dimp.size as product_size
        , dimp.weight
        , dimp.daystomanufacture
        , dimp.productline
        , dimp.class as product_class
        , dimp.style as product_style
        , dimp.productmodelid
        , dimp.sellstartdate
        , dimp.sellenddate
        , dimp.discontinueddate
        , dimst.territory_group
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
