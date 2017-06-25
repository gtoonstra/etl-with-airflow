-- Add new active records for customers we don't have in the dimension yet.

INSERT INTO TABLE dim_customer_new
SELECT 
        n.id + COALESCE(m.max_id, 0), -- new id for dim_customer_key
        n.customer_id,
        n.cust_name,
        n.street,
        n.city,
        1,
        TO_DATE('${ds}'),   -- current timestamp for scd_start_date
        TO_DATE('9999-12-31'),   -- default timestamp for scd_end_date
        true -- true for scd_active
FROM (
  SELECT 
          row_number() OVER () AS id,
          s.customer_id,
          s.cust_name,
          s.street,
          s.city
  FROM 
            customer_staging s 
  LEFT JOIN dim_customer p ON p.customer_id = s.customer_id
  WHERE 
          s.change_date = ${ds_nodash}
  AND     p.customer_id IS NULL  
) n,
(
  SELECT MAX(dim_customer_key) AS max_id
  FROM dim_customer_new
) m;
