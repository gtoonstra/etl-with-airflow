INSERT INTO datavault.sat_orderline
(l_orderline_id,
 load_dts,
 quantity,
 price)
SELECT 
        lol.l_orderline_id
      , current_timestamp
      , quantity
      , price
FROM
             staging.orderline ol
INNER JOIN   datavault.hub_order ho ON ol.order_id = ho.order_id AND ho.h_rsrc = %(r_src)s
INNER JOIN   datavault.hub_product hp ON ol.product_id = hp.product_id AND hp.h_rsrc = %(r_src)s
INNER JOIN   datavault.link_orderline lol ON hp.h_product_id = lol.h_product_id AND ho.h_order_id = lol.h_order_id
