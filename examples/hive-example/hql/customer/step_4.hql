-- Copy inactive historical records from the existing
-- dimension, apply SCD type 1 changes where required

INSERT INTO TABLE dim_customer_new
SELECT 
        p.dim_customer_key,
        p.customer_id,
        s.cust_name,
        p.street,
        p.city,
        p.scd_version,
        p.scd_start_date,
        p.scd_end_date,
        p.scd_active
FROM 
        dim_customer p
JOIN    customer_staging s ON p.customer_id = s.customer_id 
AND     p.scd_active = false
AND     s.change_date = ${ds_nodash};
