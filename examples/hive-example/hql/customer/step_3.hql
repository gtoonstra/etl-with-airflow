-- Copy existing (historical) records from the existing dimension
-- that we don't see in staging.

INSERT INTO TABLE dim_customer_new
SELECT 
            p.*
FROM 
            dim_customer p
LEFT JOIN   (SELECT customer_id FROM customer_staging s WHERE s.change_date = ${ds_nodash}) s ON p.customer_id = s.customer_id
WHERE 
            s.customer_id IS NULL;
