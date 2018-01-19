INSERT INTO datavault.sat_customer
(h_customer_id,
 load_dts,
 cust_name,
 street,
 city)
SELECT 
        hc.h_customer_id
      , current_timestamp
      , cust_name
      , street
      , city
FROM
             staging.customer c
INNER JOIN   datavault.hub_customer hc ON c.customer_id = hc.customer_id AND hc.h_rsrc = %(r_src)s
