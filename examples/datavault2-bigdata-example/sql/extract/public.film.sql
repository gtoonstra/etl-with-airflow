SELECT row_to_json(t)
FROM (
  SELECT 
          film_id,
          title,
          description,
          release_year,
          rental_duration,
          rental_rate,
          length,
          replacement_cost,
          rating,
          special_features,
          fulltext,
          (
            SELECT 
                   array_to_json(array_agg(row_to_json(fl)))
            FROM (
              SELECT
                    name
              FROM 
                    language l
              WHERE 
                    l.language_id = f.language_id
            ) fl
          ) AS languages,
          (
            SELECT 
                   array_to_json(array_agg(row_to_json(fc)))
            FROM (
              SELECT 
                    c.name
              FROM 
                    category c INNER JOIN film_category fc ON c.category_id = fc.category_id
              WHERE 
                    fc.film_id = f.film_id
            ) fc
          ) as categories,
          (
            SELECT 
                   array_to_json(array_agg(row_to_json(fa)))
            FROM (
              SELECT 
                    a.first_name,
                    a.last_name
              FROM 
                    actor a INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
              WHERE 
                    fa.film_id = f.film_id
            ) fa
          ) as actors
  FROM 
        film f
) AS t
