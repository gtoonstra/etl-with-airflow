SELECT
          so.create_dtm
        , sol.product_id
        , hc.customer_id
        , ho.order_id
        , -1
        , sol.quantity
        , sol.price
FROM
            datavault.sat_orderline sol
INNER JOIN  datavault.link_orderline lol ON sol.l_orderline_id = lol.l_orderline_id AND sol.is_current = TRUE
INNER JOIN  datavault.hub_order ho    ON    lol.h_order_id     = ho.h_order_id
INNER JOIN  datavault.hub_product  hp ON    lol.h_product_id   = hp.h_product_id
INNER JOIN  datavault.link_order lo   ON    lo.h_order_id      = ho.h_order_id
INNER JOIN  datavault.hub_customer hc ON    lo.h_customer_id   = hc.h_customer_id
INNER JOIN  datavault.sat_order so    ON    hc.h_order_id      = so.h_order_id AND so.is_current = TRUE
