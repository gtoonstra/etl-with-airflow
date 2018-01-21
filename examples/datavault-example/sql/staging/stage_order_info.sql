SELECT 
        order_id
      , customer_id
      , create_dtm
FROM
      order_info o
WHERE
      o.create_dtm >= %(window_start_date)s
AND   o.create_dtm <  %(window_end_date)s

