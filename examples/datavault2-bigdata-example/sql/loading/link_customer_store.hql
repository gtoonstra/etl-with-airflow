INSERT INTO TABLE dv_raw.link_customer_store
SELECT DISTINCT
    cs.dv__bk as hkey_customer_store,
    cs.customer_bk as hkey_customer,
    cs.store_bk as hkey_store,
    cs.dv__rec_source as record_source,
    cs.dv__load_dtm as load_dtm
FROM
    staging_dvdrentals.customer_store_{{ts_nodash}} cs
WHERE
    NOT EXISTS (
        SELECT 
                lcs.hkey_customer_store
        FROM    dv_raw.link_customer_store lcs
        WHERE 
                lcs.hkey_customer = cs.customer_bk
        AND     lcs.hkey_store = cs.store_bk
    )
