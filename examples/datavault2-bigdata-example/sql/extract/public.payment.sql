SELECT row_to_json(t)
FROM (
  SELECT 
          payment_id,
          customer_id,
          staff_id,
          rental_id,
          amount,
          payment_date
  FROM 
        payment p
  WHERE
        p.payment_date >= '{{ds}}' AND p.payment_date < '{{tomorrow_ds}}'
) AS t
