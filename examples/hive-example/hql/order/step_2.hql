set hive.exec.dynamic.partition.mode=nonstrict;

INSERT OVERWRITE TABLE fact_order PARTITION (sales_date)
SELECT 
          o.order_id
        , ol.orderline_id
        , c.dim_customer_key
        , p.dim_product_key
        , ol.quantity
        , ol.price
        , o.create_dtm
        , TRUNC(o.create_dtm, 'DD') as sales_date
FROM 
            order_info_staging o INNER JOIN orderline_staging ol ON o.order_id = ol.order_id
INNER JOIN  dim_customer c ON o.customer_id = c.customer_id
INNER JOIN  dim_product p ON ol.product_id = p.product_id
WHERE
        c.scd_start_date <= o.create_dtm
AND     c.scd_end_date > o.create_dtm
AND     p.scd_start_date <= o.create_dtm 
AND     p.scd_end_date > o.create_dtm;
