SELECT row_to_json(t)
FROM (
  SELECT 
          customer_id,
          store_id,
          first_name,
          last_name,
          email,
          activebool,
          create_date,
          active,
          address,
          address2,
          district,
          postal_code,
          phone,
          city,
          country
  FROM 
             customer c
  INNER JOIN address a ON c.address_id = a.address_id
  INNER JOIN city i ON a.city_id = i.city_id
  INNER JOIN country o ON i.country_id = o.country_id
  WHERE
        c.create_date >= '{{ds}}' AND c.create_date < '{{tomorrow_ds}}'
) AS t
