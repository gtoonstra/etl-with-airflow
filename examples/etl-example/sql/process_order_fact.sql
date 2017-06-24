-- For the specific window of interest,
-- remove the lines from the fact table.
DELETE FROM 
    dwh.fact_orderline fo
USING
    staging.orderline ol
WHERE
    ol.orderline_id = fo.orderline_id
AND ol.partition_dtm >= %(window_start_date)s 
AND ol.partition_dtm < %(window_end_date)s;

-- Repopulate fact orderline with data specific for that date
-- making sure to select the correct dimension keys.
INSERT INTO dwh.fact_orderline( 
      order_date_key
    , time_key
    , product_key
    , customer_key
    , order_id
    , orderline_id
    , quantity
    , price ) 
SELECT
      d.date_pk
    , t.time_pk
    , p.product_key
    , c.customer_key
    , o.order_id
    , ol.orderline_id
    , ol.quantity
    , ol.price
FROM
           staging.order_info o 
INNER JOIN staging.orderline ol ON o.order_id = ol.order_id
INNER JOIN dwh.dim_date d ON d.date_pk = o.create_dtm::date
INNER JOIN dwh.dim_time t ON t.time_pk = date_trunc('minute', o.create_dtm::time)
INNER JOIN dwh.dim_product p ON p.product_id = ol.product_id AND ol.partition_dtm >= p.start_dtm AND ol.partition_dtm < p.end_dtm
INNER JOIN dwh.dim_customer c ON c.customer_id = o.customer_id AND ol.partition_dtm >= c.start_dtm AND ol.partition_dtm < c.end_dtm
WHERE
    ol.partition_dtm >= %(window_start_date)s 
AND ol.partition_dtm < %(window_end_date)s;
