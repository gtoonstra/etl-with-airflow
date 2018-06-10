INSERT INTO TABLE dv_raw.link_customer_address
SELECT DISTINCT
    upper(md5(concat(ca.hkey_customer, ca.hkey_address))) as hkey_customer_address,
    ca.record_source,
    ca.load_dtm,
    ca.hkey_customer,
    ca.hkey_address,
FROM
    staging_dvdrentals.link_customer_address_{{ts_nodash}} ca
WHERE
    NOT EXISTS (
        SELECT 
                lca.hkey_customer_address
        FROM    dv_raw.link_customer_address lca
        WHERE 
                lca.hkey_customer = ca.hkey_customer
        AND     lca.hkey_address = ca.hkey_address
    )
