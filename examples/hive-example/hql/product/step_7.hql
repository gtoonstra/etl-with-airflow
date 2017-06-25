-- Add active records that have SCD type2 changes
-- (this step creates a new active record if needed)

INSERT INTO TABLE dim_product_new
SELECT 
        n.id + COALESCE(m.max_id, 0), -- new id for dim_product_key
        n.product_id,
        n.product_name,
        n.supplier_id,
        n.producttype_id,
        n.scd_version,
        TO_DATE('${ds}'), -- current timestamp for scd_start_date
        TO_DATE('9999-12-31'), -- default timestamp for scd_end_date
        true -- true for scd_active
FROM (
  SELECT 
          row_number() OVER () AS id,
          p.product_id,
          s.product_name,
          s.supplier_id,
          s.producttype_id,
          p.scd_version + 1 AS scd_version
  FROM 
          dim_product      p 
  JOIN    product_staging s ON p.product_id = s.product_id AND p.scd_active = true AND s.change_date = ${ds_nodash}
  WHERE 
          p.producttype_id != s.producttype_id
  OR      p.supplier_id != s.supplier_id
) n,
(
  SELECT MAX(dim_product_key) AS max_id
  FROM dim_product_new
) m;
