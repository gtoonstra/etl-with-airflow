-- Regenerate entire dimension from scratch.

FROM (SELECT
          row_number() OVER () AS dim_customer_key
        , customer_id
        , LEAD(customer_id) OVER (PARTITION BY customer_id ORDER BY change_date) as id_lead
        , LAST_VALUE(cust_name) OVER (PARTITION BY customer_id ORDER BY change_date RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as cust_name
        , row_number() OVER (PARTITION BY customer_id ORDER BY change_date) AS scd_version
        , street
        , city
        , change_date
        , LEAD(change_date) OVER (PARTITION BY customer_id ORDER BY change_date) as end_date
    FROM
        customer_staging) a
INSERT OVERWRITE TABLE dim_customer PARTITION(scd_active='T')
SELECT a.dim_customer_key, a.customer_id, a.cust_name, a.street, a.city, scd_version, TO_DATE(a.change_date) as scd_start_date, TO_DATE('9999-12-31') as scd_end_date
WHERE a.id_lead IS NULL

INSERT OVERWRITE TABLE dim_customer PARTITION(scd_active='F')
SELECT a.dim_customer_key, a.customer_id, a.cust_name, a.street, a.city, scd_version, TO_DATE(a.change_date) as scd_start_date, TO_DATE(a.end_date) as scd_end_date
WHERE a.id_lead = a.customer_id;
