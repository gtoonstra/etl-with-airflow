-- Add active records that have SCD type2 changes
-- (this step creates a new active record if needed)

INSERT INTO TABLE dim_customer_new
SELECT 
        n.id + COALESCE(m.max_id, 0), -- new id for dim_customer_key
        n.customer_id,
        n.cust_name,
        n.street,
        n.city,
        n.scd_version,
        TO_DATE('${ds}'), -- current timestamp for scd_start_date
        TO_DATE('9999-12-31'), -- default timestamp for scd_end_date
        true -- true for scd_active
FROM (
  SELECT 
          row_number() OVER () AS id,
          p.customer_id,
          s.cust_name,
          s.street,
          s.city,
          p.scd_version + 1 AS scd_version
  FROM 
          dim_customer     p 
  JOIN    customer_staging s ON p.customer_id = s.customer_id AND p.scd_active = true AND s.change_date = ${ds_nodash}
  WHERE 
          p.street != s.street
  OR      p.city   != s.city
) n,
(
  SELECT MAX(dim_customer_key) AS max_id
  FROM dim_customer_new
) m;
