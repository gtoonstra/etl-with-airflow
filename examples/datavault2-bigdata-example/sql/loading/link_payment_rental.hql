INSERT INTO TABLE dv_raw.link_payment_rental
SELECT DISTINCT
    pr.dv__bk as hkey_payment_rental,
    pr.payment_bk as hkey_payment,
    pr.rental_bk as hkey_rental,
    pr.dv__rec_source as record_source,
    from_unixtime(unix_timestamp(pr.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
FROM
    staging_dvdrentals.payment_rental_{{ts_nodash}} pr
WHERE
    NOT EXISTS (
        SELECT 
                lpr.hkey_payment_rental
        FROM    dv_raw.link_payment_rental lpr
        WHERE 
                lpr.hkey_payment = pr.payment_bk
        AND     lpr.hkey_rental = pr.rental_bk
    )
