INSERT INTO TABLE dv_raw.link_customer_address
SELECT DISTINCT
    c.customer_address_bk as hkey_customer_address,
    c.dv__bk as hkey_customer,
    c.address_bk as hkey_address,
    c.dv__rec_source as record_source,
    c.dv__load_dtm as load_dtm
FROM
    staging_dvdrentals.customer_{{ts_nodash}} c
WHERE
    NOT EXISTS (
        SELECT 
                lca.hkey_customer_address
        FROM    dv_raw.link_customer_address lca
        WHERE 
                lca.hkey_customer = c.dv__bk
        AND     lca.hkey_address = c.address_bk
    )
