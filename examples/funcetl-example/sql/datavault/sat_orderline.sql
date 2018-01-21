-- Create a temporary table for orderline operations
CREATE TEMP TABLE merge_orderline (LIKE datavault.sat_orderline);

INSERT INTO merge_orderline
SELECT 
      lol.l_orderline_id
    , %(load_dts)s
    , TRUE
    , ol.quantity
    , ol.price
FROM
             staging.orderline ol
INNER JOIN   datavault.hub_order ho ON ol.order_id = ho.order_id AND ho.h_rsrc = %(r_src)s
INNER JOIN   datavault.hub_product hp ON ol.product_id = hp.product_id AND hp.h_rsrc = %(r_src)s
INNER JOIN   datavault.link_orderline lol ON hp.h_product_id = lol.h_product_id AND ho.h_order_id = lol.h_order_id;

-- Update records by setting is_current flag
-- it is currently the active record
-- and values are not equal (see EXCEPT)
UPDATE
        datavault.sat_orderline target
SET
        is_current = FALSE
FROM
        merge_orderline source
WHERE
        target.l_orderline_id  = source.l_orderline_id
AND     target.is_current  = TRUE
AND EXISTS (
        SELECT source.quantity, source.price
        EXCEPT
        SELECT target.quantity, target.price);

-- Remove records that we do not want to insert.
-- What we do insert:
--   1. No record in target
--   2. record in target, but source is newer and target has no current record.
DELETE FROM
    merge_orderline source
USING
    datavault.sat_orderline target
WHERE
    target.l_orderline_id = source.l_orderline_id
AND target.is_current = TRUE
AND EXISTS (
        SELECT source.l_orderline_id, source.quantity, source.price
        INTERSECT
        SELECT target.l_orderline_id, target.quantity, target.price);

-- Now perform the inserts.
INSERT INTO datavault.sat_orderline (l_orderline_id, load_dts, is_current, quantity, price )
SELECT
      source.l_orderline_id
    , source.load_dts
    , source.is_current
    , source.quantity
    , source.price
FROM
    merge_orderline source;

-- Temp table cleared at end of session
