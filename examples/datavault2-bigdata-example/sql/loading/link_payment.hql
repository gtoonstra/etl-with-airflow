INSERT INTO TABLE dv_raw.link_payment
SELECT DISTINCT
    upper(md5(concat(p.customer_bk, p.rental_bk, p.staff_bk))) as hkey_payment,
    p.record_source,
    p.load_dtm,
    p.customer_bk as hkey_customer,
    p.rental_bk as hkey_rental,
    p.staff_bk as hkey_staff
FROM
    staging_dvdrentals.payment_{{ts_nodash}} p
WHERE
    NOT EXISTS (
        SELECT 
                lp.hkey_payment
        FROM    dv_raw.link_payment lp
        WHERE 
                lp.hkey_customer = p.customer_bk
        AND     lp.hkey_rental = p.rental_bk
        AND     lp.hkey_staff = p.staff_bk
    )
