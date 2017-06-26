-- Make sure a fact table exists of the right type

DROP TABLE IF EXISTS fact_order;

CREATE TABLE IF NOT EXISTS fact_order (
      order_id INT
    , orderline_id INT
    , dim_customer_key BIGINT
    , dim_product_key BIGINT
    , quantity INT
    , price DOUBLE
    , create_dtm TIMESTAMP
)
PARTITIONED BY  (sales_date STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\001'
STORED AS ORC;
