-- Create a temporary table for order operations
CREATE TEMP TABLE merge_order (LIKE datavault.sat_order);

INSERT INTO merge_order
SELECT 
      ho.h_order_id
    , %(load_dts)s
    , TRUE
    , o.create_dtm
FROM
           staging.order_info o
INNER JOIN datavault.hub_order ho ON o.order_id = ho.order_id AND ho.h_rsrc = %(r_src)s;

-- Update records by setting is_current flag
-- it is currently the active record
-- and values are not equal (see EXCEPT)
UPDATE
        datavault.sat_order target
SET
        is_current = FALSE
FROM
        merge_order source
WHERE
        target.h_order_id  = source.h_order_id
AND     target.is_current  = TRUE
AND EXISTS (
        SELECT source.create_dtm
        EXCEPT
        SELECT target.create_dtm);

-- Remove records that we do not want to insert.
-- What we do insert:
--   1. No record in target
--   2. record in target, but source is newer and target has no current record.
DELETE FROM
    merge_order source
USING
    datavault.sat_order target
WHERE
    target.h_order_id = source.h_order_id
AND target.is_current = TRUE
AND EXISTS (
        SELECT source.h_order_id, source.create_dtm
        INTERSECT
        SELECT target.h_order_id, target.create_dtm);

-- Now perform the inserts.
INSERT INTO datavault.sat_order (h_order_id, load_dts, is_current, create_dtm )
SELECT
      source.h_order_id
    , source.load_dts
    , source.is_current
    , source.create_dtm
FROM
    merge_order source;

-- Temp table cleared at end of session
