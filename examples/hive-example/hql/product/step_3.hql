-- Copy existing (historical) records from the existing dimension
-- that we don't see in staging.

INSERT INTO TABLE dim_product_new
SELECT 
            p.*
FROM 
            dim_product p
LEFT JOIN   (SELECT product_id FROM product_staging s WHERE s.change_date = ${ds_nodash}) s ON p.product_id = s.product_id
WHERE 
            s.product_id IS NULL; 
