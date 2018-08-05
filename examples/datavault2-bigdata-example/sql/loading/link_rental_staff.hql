INSERT INTO TABLE dv_raw.link_rental_staff
SELECT DISTINCT
    r.dv__bk as hkey_rental_staff,
    r.rental_bk as hkey_rental,
    r.staff_bk as hkey_staff,
    r.dv__rec_source as record_source,
    r.dv__load_dtm as load_dtm
FROM
    staging_dvdrentals.rental_staff_{{ts_nodash}} r
WHERE
    NOT EXISTS (
        SELECT 
                lr.hkey_rental_staff
        FROM    dv_raw.link_rental_staff lr
        WHERE 
                lr.hkey_rental = r.rental_bk
        AND     lr.hkey_staff = r.staff_bk
    )
