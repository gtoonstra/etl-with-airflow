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
    , s.order_id
    , s.orderline_id
    , s.quantity
    , s.price
FROM
           staging.order_facts s
INNER JOIN dwh.dim_date d        ON d.date_pk = s.create_dtm::date
INNER JOIN dwh.dim_time t        ON t.time_pk = date_trunc('minute', s.create_dtm::time)
INNER JOIN dwh.dim_product p     ON p.product_id = s.product_id
INNER JOIN dwh.dim_customer c    ON c.customer_id = s.customer_id AND s.create_dtm >= c.start_dtm AND s.create_dtm < c.end_dtm
