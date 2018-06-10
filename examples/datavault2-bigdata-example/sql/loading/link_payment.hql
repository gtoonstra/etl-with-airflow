INSERT INTO TABLE dv_raw.link_payment
SELECT DISTINCT
    upper(md5(concat(p.hkey_film, p.hkey_category))) as hkey_payment,
    p.record_source,
    p.load_dtm,
    p.hkey_customer,
    p.hkey_rental,
    p.hkey_staff
FROM
    staging_dvdrentals.payment_{{ts_nodash}} p
WHERE
    NOT EXISTS (
        SELECT 
                lca.hkey_payment
        FROM    dv_raw.link_payment lp
        WHERE 
                lp.hkey_customer = p.hkey_customer
        AND     lp.hkey_rental = p.hkey_rental
        AND     lp.hkey_staff = p.hkey_staff
    )
