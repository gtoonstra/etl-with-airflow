SELECT 
        customer_id
      , cust_name
      , street
      , city
FROM
      customer
WHERE
      updated_dtm >= %(window_start_date)s
AND   updated_dtm <  %(window_end_date)s
