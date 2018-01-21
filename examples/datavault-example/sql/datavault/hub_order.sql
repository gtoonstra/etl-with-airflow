INSERT INTO datavault.hub_order
(order_id,
 h_rsrc,
 load_audit_id)
SELECT 
        so.order_id as order_id
      , %(r_src)s as h_rsrc
      , %(audit_id)s as load_audit_id
FROM
            staging.order_info so
LEFT JOIN   datavault.hub_order ho ON so.order_id = ho.order_id AND ho.h_rsrc = %(r_src)s
WHERE
            ho.order_id IS NULL
