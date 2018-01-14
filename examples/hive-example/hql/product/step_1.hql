-- Make sure a dimension table exists of the right type

DROP TABLE IF EXISTS dim_product;

CREATE TABLE IF NOT EXISTS dim_product (
      dim_product_key BIGINT
    , product_id STRING
    , product_name STRING
    , supplier_id INT
    , producttype_id INT
    , scd_version INT -- historical version of the record (1 is the oldest)
    , scd_start_date DATE -- start date
    , scd_end_date DATE -- end date and time (9999-12-31 by default)
)
PARTITIONED BY  (scd_active STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\001'
STORED AS ORC;
