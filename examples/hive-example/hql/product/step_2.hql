-- Start by creating a new dimension table, which we use to copy over the production one.

DROP TABLE IF EXISTS dim_product_new;

CREATE TABLE dim_product_new
LIKE dim_product
STORED AS ORC;
