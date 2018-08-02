SELECT row_to_json(t)
FROM (
  SELECT 
          staff_id,
          first_name,
          last_name,
          email,
          store_id,
          active,
          username,
          password,
          address,
          address2,
          district,
          postal_code,
          phone,
          city,
          country
  FROM 
             staff s
  INNER JOIN address a ON s.address_id = a.address_id
  INNER JOIN city i ON a.city_id = i.city_id
  INNER JOIN country o ON i.country_id = o.country_id
) AS t
