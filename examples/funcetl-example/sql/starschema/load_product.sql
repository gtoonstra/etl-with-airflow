SELECT
          hp.product_id
        , sp.product_name
        , sp.supplier_id
        , sp.producttype_id
        , TIMESTAMP '1900-01-01' as start_dtm
        , TIMESTAMP '9999-01-01' as end_dtm
FROM
        datavault.sat_product sp INNER JOIN datavault.hub_product hp ON sp.h_product_id = hp.h_product_id and sp.is_current = TRUE
ORDER BY
        hp.product_id
