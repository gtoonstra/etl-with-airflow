SELECT
          hc.customer_id
        , sc.cust_name
        , sc.street
        , sc.city
        , sc.load_dts as start_dtm
        , CASE WHEN sc.is_current THEN TIMESTAMP '9999-01-01' ELSE LEAD(sc.load_dts) OVER (ORDER BY hc.customer_id, sc.load_dts) END AS end_dtm
FROM
        datavault.sat_customer sc INNER JOIN datavault.hub_customer hc ON sc.h_customer_id = hc.h_customer_id
ORDER BY
          hc.customer_id
        , sc.load_dts
