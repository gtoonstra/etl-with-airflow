INSERT INTO TABLE dv_raw.link_rental_customer
SELECT DISTINCT
    r.dv__bk as hkey_rental_customer,
    r.rental_bk as hkey_rental,
    r.customer_bk as hkey_customer,
    r.dv__rec_source as record_source,
    from_unixtime(unix_timestamp(r.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
FROM
    staging_dvdrentals.rental_customer_{{ts_nodash}} r
WHERE
    NOT EXISTS (
        SELECT 
                lr.hkey_rental_customer
        FROM    dv_raw.link_rental_customer lr
        WHERE 
                lr.hkey_rental = r.rental_bk
        AND     lr.hkey_customer = r.customer_bk
    )
