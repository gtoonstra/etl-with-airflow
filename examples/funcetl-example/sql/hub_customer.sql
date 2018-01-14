SELECT 
        customer_id
      , %(audit_id)s
      , %(window_start_date)s
FROM
      customer
WHERE
      updated_dtm >= %(window_start_date)s
AND   updated_dtm <  %(window_end_date)s
