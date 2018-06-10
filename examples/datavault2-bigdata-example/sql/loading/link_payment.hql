INSERT INTO TABLE dv_raw.link_payment
SELECT DISTINCT
    p.dv__bk as hkey_payment,
    p.dv__rec_source as record_source,
    p.dv__load_dtm as load_dtm,
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
