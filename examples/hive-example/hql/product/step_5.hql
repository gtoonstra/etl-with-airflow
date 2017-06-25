-- Copy all active records with records in staging
-- that do not have SCD type 2 changes (so no need to close records or 
-- create new ones)

INSERT INTO TABLE dim_product_new
SELECT 
        p.dim_product_key,
        p.product_id,
        s.product_name,
        p.supplier_id,
        p.producttype_id,
        p.scd_version,
        p.scd_start_date,
        p.scd_end_date,
        p.scd_active
FROM 
        dim_product p 
JOIN    product_staging s ON p.product_id = s.product_id AND p.scd_active = true AND s.change_date = ${ds_nodash}
WHERE 
        p.producttype_id = s.producttype_id
AND     p.supplier_id = s.supplier_id;
