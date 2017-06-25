-- Add new active records for products we don't have in the dimension yet.

INSERT INTO TABLE dim_product_new
SELECT 
        n.id + COALESCE(m.max_id, 0), -- new id for dim_product_key
        n.product_id,
        n.product_name,
        n.supplier_id,
        n.producttype_id,
        1,
        TO_DATE('${ds}'),   -- current timestamp for scd_start_date
        TO_DATE('9999-12-31'),   -- default timestamp for scd_end_date
        true -- true for scd_active
FROM (
  SELECT 
          row_number() OVER () AS id,
          s.product_id,
          s.product_name,
          s.supplier_id,
          s.producttype_id
  FROM 
            product_staging s 
  LEFT JOIN dim_product p ON p.product_id = s.product_id
  WHERE 
          p.product_id IS NULL
  AND     s.change_date = ${ds_nodash}
) n,
(
  SELECT MAX(dim_product_key) AS max_id
  FROM dim_product_new
) m;
