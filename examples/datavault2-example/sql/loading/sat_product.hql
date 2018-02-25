INSERT INTO TABLE dv_raw.sat_product
SELECT DISTINCT
      p.hkey_product
    , p.load_dtm
    , NULL
    , p.record_source
    , p.productid
    , p.name
    , p.makeflag
    , p.finishedgoodsflag
    , p.color
    , p.safetystocklevel
    , p.reorderpoint
    , p.standardcost
    , p.listprice
    , p.size
    , p.weight
    , p.daystomanufacture
    , p.productline
    , p.class
    , p.style
    , p.productmodelid
    , p.sellstartdate
    , p.sellenddate
    , p.discontinueddate
FROM
                advworks_staging.product_{{ts_nodash}} p
LEFT OUTER JOIN dv_raw.sat_product sat ON (
                sat.hkey_product = p.hkey_product
            AND sat.load_end_dtm IS NULL)
WHERE
   COALESCE(p.productid, '') != COALESCE(sat.productid, '')
OR COALESCE(p.name, '') != COALESCE(sat.name, '')
OR COALESCE(p.makeflag, '') != COALESCE(sat.makeflag, '')
OR COALESCE(p.finishedgoodsflag, '') != COALESCE(sat.finishedgoodsflag, '')
OR COALESCE(p.color, '') != COALESCE(sat.color, '')
OR COALESCE(p.safetystocklevel, '') != COALESCE(sat.safetystocklevel, '')
OR COALESCE(p.reorderpoint, '') != COALESCE(sat.reorderpoint, '')
OR COALESCE(p.standardcost, '') != COALESCE(sat.standardcost, '')
OR COALESCE(p.listprice, '') != COALESCE(sat.listprice, '')
OR COALESCE(p.size, '') != COALESCE(sat.size, '')
OR COALESCE(p.weight, '') != COALESCE(sat.weight, '')
OR COALESCE(p.daystomanufacture, '') != COALESCE(sat.daystomanufacture, '')
OR COALESCE(p.productline, '') != COALESCE(sat.productline, '')
OR COALESCE(p.class, '') != COALESCE(sat.class, '')
OR COALESCE(p.style, '') != COALESCE(sat.style, '')
OR COALESCE(p.productmodelid, '') != COALESCE(sat.productmodelid, '')
OR COALESCE(p.sellstartdate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET')) != COALESCE(sat.sellstartdate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET'))
OR COALESCE(p.sellenddate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET')) != COALESCE(sat.sellenddate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET'))
OR COALESCE(p.discontinueddate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET')) != COALESCE(sat.discontinueddate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET'))
