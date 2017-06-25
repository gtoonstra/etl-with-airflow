-- Create a temporary table for customer operations
CREATE TEMP TABLE merge_product (LIKE dwh.dim_product);

-- The customer_key is allocated later.
-- The staging table should only have at most one record per customer
INSERT INTO merge_product
SELECT 
    0, p.product_id, p.product_name, p.supplier_id, p.producttype_id, p.partition_dtm, TIMESTAMP '9999-01-01'
FROM
    staging.product p
WHERE 
    p.partition_dtm >= %(window_start_date)s
AND p.partition_dtm < %(window_end_date)s;

-- Update records by setting an end date
-- only do this when start_dtm < to be inserted dtm,
-- it is currently the active record
-- and when values are not equal (see EXCEPT)
UPDATE
        dwh.dim_product target
SET
        end_dtm = source.start_dtm
FROM
        merge_product source
WHERE
        target.product_id  = source.product_id
AND     target.end_dtm     >= TIMESTAMP '9999-01-01'
AND     target.start_dtm   < source.start_dtm
AND EXISTS (
        SELECT source.product_id, source.product_name, source.supplier_id, source.producttype_id
        EXCEPT
        SELECT target.product_id, target.product_name, target.supplier_id, target.producttype_id);

-- Remove records that we do not want to insert.
-- What we do want to insert are all new records (nothing in target),
-- or when there is something in target, only when the record is newer
-- than most recent and when the old record is closed.
-- The closure should have been done in the previous step.
DELETE FROM
    merge_product source
USING
    dwh.dim_product target
WHERE
    target.product_id  = source.product_id
AND target.end_dtm    >= TIMESTAMP '9999-01-01'
AND target.start_dtm  <= source.start_dtm
AND EXISTS (
        SELECT source.product_id, source.product_name, source.supplier_id, source.producttype_id
        INTERSECT
        SELECT target.product_id, target.product_name, target.supplier_id, target.producttype_id);

-- Now perform the inserts. These are new customers and records for customers
-- Where these may have changed.
INSERT INTO dwh.dim_product (product_id, product_name, supplier_id, producttype_id, start_dtm )
SELECT
      source.product_id
    , source.product_name
    , source.supplier_id
    , source.producttype_id
    , source.start_dtm
FROM
    merge_product source;

-- The temp table is automatically removed at the end of the session...


