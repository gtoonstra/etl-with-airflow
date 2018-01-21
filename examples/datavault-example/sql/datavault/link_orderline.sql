INSERT INTO datavault.link_orderline
(h_order_id,
 h_product_id,
 h_rsrc,
 load_audit_id)
SELECT 
        ho.h_order_id
      , hp.h_product_id
      , %(r_src)s as h_rsrc
      , %(audit_id)s as load_audit_id
FROM
            staging.orderline ol
LEFT JOIN   datavault.hub_order ho ON ol.order_id = ho.order_id AND ho.h_rsrc = %(r_src)s
LEFT JOIN   datavault.hub_product hp ON ol.product_id = hp.product_id AND hp.h_rsrc = %(r_src)s
LEFT JOIN   datavault.link_orderline lol ON hp.h_product_id = lol.h_product_id AND ho.h_order_id = lol.h_order_id
WHERE
            lol.l_orderline_id IS NULL
