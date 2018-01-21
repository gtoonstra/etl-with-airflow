INSERT INTO datavault.link_order
(h_order_id,
 h_customer_id,
 h_rsrc,
 load_audit_id)
SELECT 
        ho.h_order_id
      , hc.h_customer_id
      , %(r_src)s as h_rsrc
      , %(audit_id)s as load_audit_id
FROM
            staging.order_info so
LEFT JOIN   datavault.hub_order ho ON so.order_id = ho.order_id AND ho.h_rsrc = %(r_src)s
LEFT JOIN   datavault.hub_customer hc ON so.customer_id = hc.customer_id AND hc.h_rsrc = %(r_src)s
LEFT JOIN   datavault.link_order lo ON ho.h_order_id = lo.h_order_id AND hc.h_customer_id = lo.h_customer_id
WHERE
            lo.l_order_id IS NULL
