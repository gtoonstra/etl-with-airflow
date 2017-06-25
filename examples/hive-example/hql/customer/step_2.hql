-- Start by creating a new dimension table, which we use to copy over the production one.

DROP TABLE IF EXISTS dim_customer_new;

CREATE TABLE dim_customer_new
LIKE dim_customer
STORED AS ORC;
