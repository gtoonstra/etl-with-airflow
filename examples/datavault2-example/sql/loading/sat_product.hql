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
AND COALESCE(p.name, '') != COALESCE(sat.name, '')
AND COALESCE(p.makeflag, '') != COALESCE(sat.makeflag, '')
AND COALESCE(p.finishedgoodsflag, '') != COALESCE(sat.finishedgoodsflag, '')
AND COALESCE(p.color, '') != COALESCE(sat.color, '')
AND COALESCE(p.safetystocklevel, '') != COALESCE(sat.safetystocklevel, '')
AND COALESCE(p.reorderpoint, '') != COALESCE(sat.reorderpoint, '')
AND COALESCE(p.standardcost, '') != COALESCE(sat.standardcost, '')
AND COALESCE(p.listprice, '') != COALESCE(sat.listprice, '')
AND COALESCE(p.size, '') != COALESCE(sat.size, '')
AND COALESCE(p.weight, '') != COALESCE(sat.weight, '')
AND COALESCE(p.daystomanufacture, '') != COALESCE(sat.daystomanufacture, '')
AND COALESCE(p.productline, '') != COALESCE(sat.productline, '')
AND COALESCE(p.class, '') != COALESCE(sat.class, '')
AND COALESCE(p.style, '') != COALESCE(sat.style, '')
AND COALESCE(p.productmodelid, '') != COALESCE(sat.productmodelid, '')
AND COALESCE(p.sellstartdate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET')) != COALESCE(sat.sellstartdate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET'))
AND COALESCE(p.sellenddate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET')) != COALESCE(sat.sellenddate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET'))
AND COALESCE(p.discontinueddate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET')) != COALESCE(sat.discontinueddate, to_utc_timestamp ('1900-01-01 00:00:00', 'CET'))
