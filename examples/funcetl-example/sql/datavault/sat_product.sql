INSERT INTO datavault.sat_product
(h_product_id,
 load_dts,
 product_name,
 supplier_id,
 producttype_id)
SELECT 
        hp.h_product_id
      , current_timestamp
      , product_name
      , supplier_id
      , producttype_id
FROM
             staging.product p
INNER JOIN   datavault.hub_product hp ON p.product_id = hp.product_id AND hp.h_rsrc = %(r_src)s
