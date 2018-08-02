SELECT row_to_json(t)
FROM (
  SELECT 
          store_id,
          manager_staff_id,
          address,
          address2,
          district,
          postal_code,
          phone,
          city,
          country
  FROM 
             store s
  INNER JOIN address a ON s.address_id = a.address_id
  INNER JOIN city i ON a.city_id = i.city_id
  INNER JOIN country o ON i.country_id = o.country_id
) AS t
