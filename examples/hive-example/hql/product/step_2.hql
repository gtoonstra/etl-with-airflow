-- Regenerate entire dimension from scratch.

FROM (SELECT
          row_number() OVER () AS dim_product_key
        , product_id
        , LEAD(product_id) OVER (PARTITION BY product_id ORDER BY change_date) as id_lead
        , LAST_VALUE(product_name) OVER (PARTITION BY product_id ORDER BY change_date RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as product_name
        , row_number() OVER (PARTITION BY product_id ORDER BY change_date) AS scd_version
        , supplier_id
        , producttype_id
        , change_date
        , LEAD(change_date) OVER (PARTITION BY product_id ORDER BY change_date) as end_date
    FROM
        product_staging) a
INSERT OVERWRITE TABLE dim_product PARTITION(scd_active='T')
SELECT a.dim_product_key, a.product_id, a.product_name, a.supplier_id, a.producttype_id, scd_version, TO_DATE(a.change_date) as scd_start_date, TO_DATE('9999-12-31') as scd_end_date
WHERE a.id_lead IS NULL

INSERT OVERWRITE TABLE dim_product PARTITION(scd_active='F')
SELECT a.dim_product_key, a.product_id, a.product_name, a.supplier_id, a.producttype_id, scd_version, TO_DATE(a.change_date) as scd_start_date, TO_DATE(a.end_date) as scd_end_date
WHERE a.id_lead = a.product_id;
