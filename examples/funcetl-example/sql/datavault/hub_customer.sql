INSERT INTO datavault.hub_customer
(customer_id,
 h_rsrc,
 load_audit_id)
SELECT 
        sc.customer_id as customer_id
      , %(r_src)s as h_rsrc
      , %(audit_id)s as load_audit_id
FROM
            staging.customer sc 
LEFT JOIN   datavault.hub_customer hc ON sc.customer_id = hc.customer_id AND hc.h_rsrc = %(r_src)s
WHERE
            hc.customer_id IS NULL
