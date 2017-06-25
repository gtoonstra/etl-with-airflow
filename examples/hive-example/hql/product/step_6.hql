-- Copy new inactive records which do have SCD type 2 changes
-- and apply SCD type 1 changes if required.
-- (this step closes the currently active record if there is one)

INSERT INTO TABLE dim_product_new
SELECT 
        p.dim_product_key,
        p.product_id,
        s.product_name,
        p.supplier_id,
        p.producttype_id,
        p.scd_version,
        p.scd_start_date,
        TO_DATE('${ds}'),
        false
FROM 
        dim_product p 
JOIN    product_staging s ON p.product_id = s.product_id AND p.scd_active = true AND s.change_date = ${ds_nodash}
WHERE 
        p.producttype_id != s.producttype_id
OR      p.supplier_id != s.supplier_id;
