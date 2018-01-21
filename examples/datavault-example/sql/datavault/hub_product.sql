INSERT INTO datavault.hub_product
(product_id,
 h_rsrc,
 load_audit_id)
SELECT 
        sp.product_id as product_id
      , %(r_src)s as h_rsrc
      , %(audit_id)s as load_audit_id
FROM
            staging.product sp
LEFT JOIN   datavault.hub_product hp ON sp.product_id = hp.product_id AND hp.h_rsrc = %(r_src)s
WHERE
            hp.product_id IS NULL
