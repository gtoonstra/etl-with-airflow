-- Make sure a dimension table exists of the right type

CREATE TABLE IF NOT EXISTS dim_customer (
      dim_customer_key BIGINT
    , customer_id STRING
    , cust_name STRING
    , street STRING
    , city STRING
    , scd_version INT -- historical version of the record (1 is the oldest)
    , scd_start_date DATE -- start date
    , scd_end_date DATE -- end date and time (9999-12-31 by default)
    , scd_active BOOLEAN -- whether it's the latest version or not
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\001'
STORED AS ORC;
