INSERT INTO TABLE dv_raw.hub_product
SELECT DISTINCT
    p.hkey_product,
    p.record_source,
    p.load_dtm,
    p.productnumber
FROM
    advworks_staging.product_{{ts_nodash}} p
WHERE
    p.productnumber NOT IN (
        SELECT hub.productnumber FROM dv_raw.hub_product hub
    )
