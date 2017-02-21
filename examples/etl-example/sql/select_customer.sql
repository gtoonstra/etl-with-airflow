SELECT 
        customer_id
      , cust_name
      , street
      , city
      , %(audit_id)s
      , %(window_start_date)s
FROM
      customer
WHERE
      updated_dtm >= %(window_start_date)s
AND   updated_dtm <  %(window_end_date)s

