-- Create a temporary table for product operations
CREATE TEMP TABLE merge_product (LIKE datavault.sat_product);

INSERT INTO merge_product
SELECT 
      hp.h_product_id
    , %(load_dts)s
    , TRUE
    , p.product_name
    , p.supplier_id
    , p.producttype_id
FROM
           staging.product p
INNER JOIN datavault.hub_product hp ON p.product_id = hp.product_id AND hp.h_rsrc = %(r_src)s;

-- Update records by setting is_current flag
-- it is currently the active record
-- and values are not equal (see EXCEPT)
UPDATE
        datavault.sat_product target
SET
        is_current = FALSE
FROM
        merge_product source
WHERE
        target.h_product_id = source.h_product_id
AND     target.is_current   = TRUE
AND EXISTS (
        SELECT source.product_name, source.supplier_id, source.producttype_id
        EXCEPT
        SELECT target.product_name, target.supplier_id, target.producttype_id);

-- Remove records that we do not want to insert.
-- What we do insert:
--   1. No record in target
--   2. record in target, but source is newer and target has no current record.
DELETE FROM
    merge_product source
USING
    datavault.sat_product target
WHERE
    target.h_product_id = source.h_product_id
AND target.is_current   = TRUE
AND EXISTS (
        SELECT source.h_product_id, source.product_name, source.supplier_id, source.producttype_id
        INTERSECT
        SELECT target.h_product_id, target.product_name, target.supplier_id, target.producttype_id);

-- Now perform the inserts.
INSERT INTO datavault.sat_product (h_product_id, load_dts, is_current, product_name, supplier_id, producttype_id )
SELECT
      source.h_product_id
    , source.load_dts
    , source.is_current
    , source.product_name
    , source.supplier_id
    , source.producttype_id
FROM
    merge_product source;

-- Temp table cleared at end of session
