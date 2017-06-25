-- Copy inactive historical records from the existing
-- dimension, apply SCD type 1 changes where required

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
JOIN    product_staging s ON p.product_id = s.product_id 
AND     p.scd_active = false
AND     s.change_date = ${ds_nodash};
