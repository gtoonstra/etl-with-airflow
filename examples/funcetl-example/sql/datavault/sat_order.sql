INSERT INTO datavault.sat_order
(h_order_id,
 load_dts,
 create_dtm)
SELECT 
        ho.h_order_id
      , current_timestamp
      , create_dtm
FROM
             staging.order_info o
INNER JOIN   datavault.hub_order ho ON o.order_id = ho.order_id AND ho.h_rsrc = %(r_src)s
