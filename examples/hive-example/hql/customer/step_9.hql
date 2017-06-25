-- Replace the current dimension with a new version

INSERT OVERWRITE TABLE dim_customer
SELECT *
FROM dim_customer_new;
