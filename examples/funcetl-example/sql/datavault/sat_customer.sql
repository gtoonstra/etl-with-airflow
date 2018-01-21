-- Create a temporary table for customer operations
CREATE TEMP TABLE merge_customer (LIKE datavault.sat_customer);

INSERT INTO merge_customer
SELECT 
      hc.h_customer_id
    , %(load_dts)s
    , TRUE
    , c.cust_name
    , c.street
    , c.city
FROM
           staging.customer c 
INNER JOIN datavault.hub_customer hc ON c.customer_id = hc.customer_id AND hc.h_rsrc = %(r_src)s;

-- Update records by setting is_current flag
-- it is currently the active record
-- and values are not equal (see EXCEPT)
UPDATE
        datavault.sat_customer target
SET
        is_current = FALSE
FROM
        merge_customer source
WHERE
        target.h_customer_id  = source.h_customer_id
AND     target.is_current     = TRUE
AND EXISTS (
        SELECT source.cust_name, source.street, source.city
        EXCEPT
        SELECT target.cust_name, target.street, target.city);

-- Remove records that we do not want to insert.
-- What we do insert:
--   1. No record in target
--   2. record in target, but source is newer and target has no current record.
DELETE FROM
    merge_customer source
USING
    datavault.sat_customer target
WHERE
    target.h_customer_id = source.h_customer_id
AND target.is_current    = TRUE
AND EXISTS (
        SELECT source.h_customer_id, source.cust_name, source.street, source.city
        INTERSECT
        SELECT target.h_customer_id, target.cust_name, target.street, target.city);

-- Now perform the inserts.
INSERT INTO datavault.sat_customer (h_customer_id, load_dts, is_current, cust_name, street, city )
SELECT
      source.h_customer_id
    , source.load_dts
    , source.is_current
    , source.cust_name
    , source.street
    , source.city
FROM
    merge_customer source;

-- Temp table cleared at end of session
