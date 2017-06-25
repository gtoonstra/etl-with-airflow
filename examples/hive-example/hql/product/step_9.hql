-- Replace the current dimension with a new version

INSERT OVERWRITE TABLE dim_product
SELECT *
FROM dim_product_new;
