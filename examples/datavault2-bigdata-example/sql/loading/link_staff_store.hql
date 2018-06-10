INSERT INTO TABLE dv_raw.link_staff_store
SELECT DISTINCT
    s.staff_store_bk as hkey_staff_store,
    s.dv__rec_source as record_source,
    s.dv__load_dtm as load_dtm,
    s.dv__bk as hkey_staff,
    s.store_bk as hkey_store
FROM
    staging_dvdrentals.staff_{{ts_nodash}} s
WHERE
    NOT EXISTS (
        SELECT 
                lss.hkey_staff_store
        FROM    dv_raw.link_staff_store lss
        WHERE 
                lss.hkey_staff = s.dv__bk
        AND     lss.hkey_store = s.store_bk
    )
