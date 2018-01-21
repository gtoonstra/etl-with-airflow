SELECT
          hp.product_id
        , sc.product_name
        , sc.supplier_id
        , sc.producttype_id
        , TIMESTAMP '1900-01-01'
        , TIMESTAMP '9999-01-01'
FROM
        datavault.sat_product sp INNER JOIN datavault.hub_product hp ON sp.h_product_id = hp.h_product_id
ORDER BY
        hp.product_id
