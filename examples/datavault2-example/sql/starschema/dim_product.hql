DROP TABLE dv_star.dim_product;

CREATE TABLE dv_star.dim_product AS
SELECT
          hub.hkey_product
        , hub.productnumber
        , sat.name
        , sat.makeflag
        , sat.finishedgoodsflag
        , sat.color
        , sat.safetystocklevel
        , sat.reorderpoint
        , sat.standardcost
        , sat.listprice
        , sat.size
        , sat.weight
        , sat.daystomanufacture
        , sat.productline
        , sat.class
        , sat.style
        , sat.productmodelid
        , sat.sellstartdate
        , sat.sellenddate
        , sat.discontinueddate
FROM
            dv_raw.sat_product sat
INNER JOIN  dv_raw.hub_product hub ON hub.hkey_product = sat.hkey_product
WHERE
        sat.load_end_dtm IS NULL;
