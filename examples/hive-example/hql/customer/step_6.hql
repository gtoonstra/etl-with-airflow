-- Copy new inactive records which do have SCD type 2 changes
-- and apply SCD type 1 changes if required.
-- (this step closes the currently active record if there is one)

INSERT INTO TABLE dim_customer_new
SELECT 
        p.dim_customer_key,
        p.customer_id,
        s.cust_name,
        p.street,
        p.city,
        p.scd_version,
        p.scd_start_date,
        TO_DATE('${ds}'),
        false
FROM 
        dim_customer p 
JOIN    customer_staging s ON p.customer_id = s.customer_id AND p.scd_active = true AND s.change_date = ${ds_nodash}
WHERE 
        p.street != s.street
OR      p.city != s.city;
