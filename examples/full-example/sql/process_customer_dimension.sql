-- Create a temporary table for customer operations
CREATE TEMP TABLE merge_customer (LIKE dwh.dim_customer);

-- The customer_key is allocated later.
-- The staging table should only have at most one record per customer
INSERT INTO merge_customer
SELECT 
    0, c.customer_id, c.cust_name, c.street, c.city, c.partition_dtm, TIMESTAMP '9999-01-01'
FROM
    staging.customer c
WHERE 
    c.partition_dtm >= %(window_start_date)s
AND c.partition_dtm < %(window_end_date)s;

-- Update records by setting an end date
-- only do this when start_dtm < to be inserted dtm,
-- it is currently the active record
-- and when values are not equal (see EXCEPT)
UPDATE
        dwh.dim_customer target
SET
        end_dtm = source.start_dtm
FROM
        merge_customer source
WHERE
        target.customer_id  = source.customer_id
AND     target.end_dtm     >= TIMESTAMP '9999-01-01'
AND     target.start_dtm    < source.start_dtm
AND EXISTS (
        SELECT source.customer_id, source.cust_name, source.street, source.city
        EXCEPT
        SELECT target.customer_id, target.cust_name, target.street, target.city);

-- Remove records that we do not want to insert.
-- What we do want to insert are all new records (nothing in target),
-- or when there is something in target, only when the record is newer
-- than most recent and when the old record is closed.
-- The closure should have been done in the previous step.
DELETE FROM
    merge_customer source
USING
    dwh.dim_customer target
WHERE
    target.customer_id  = source.customer_id
AND target.end_dtm     >= TIMESTAMP '9999-01-01'
AND target.start_dtm   <= source.start_dtm
AND EXISTS (
        SELECT source.customer_id, source.cust_name, source.street, source.city
        INTERSECT
        SELECT target.customer_id, target.cust_name, target.street, target.city);

-- Now perform the inserts. These are new customers and records for customers
-- Where these may have changed.
INSERT INTO dwh.dim_customer (customer_id, cust_name, street, city, start_dtm )
SELECT
      source.customer_id
    , source.cust_name
    , source.street
    , source.city
    , source.start_dtm
FROM
    merge_customer source;

-- The temp table is automatically removed at the end of the session...


