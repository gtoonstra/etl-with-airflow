SELECT 
        orderline_id
      , ol.order_id
      , product_id
      , quantity
      , price
FROM
      orderline ol INNER JOIN order_info o ON ol.order_id = o.order_id
WHERE
      o.create_dtm >= %(window_start_date)s
AND   o.create_dtm <  %(window_end_date)s

