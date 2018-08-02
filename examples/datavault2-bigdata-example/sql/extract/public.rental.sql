SELECT row_to_json(t)
FROM (
  SELECT 
          rental_id,
          rental_date,
          inventory_id,
          customer_id,
          return_date,
          staff_id
  FROM 
        rental r
  WHERE
        r.rental_date >= '{{ds}}' AND r.rental_date < '{{tomorrow_ds}}'
) AS t
