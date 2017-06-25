SELECT 
        product_id
      , product_name
      , supplier_id
      , producttype_id
FROM
      product
WHERE
      updated_dtm >= %(window_start_date)s
AND   updated_dtm <  %(window_end_date)s
