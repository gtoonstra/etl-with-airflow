SELECT row_to_json(t)
FROM (
  SELECT 
          inventory_id,
          film_id,
          store_id
  FROM 
        inventory i
) AS t
