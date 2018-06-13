INSERT INTO TABLE dv_raw.link_store_staff
SELECT DISTINCT
    f.dv__bk as hkey_store_staff,
    s.dv__bk as hkey_store,
    f.dv__bk as hkey_staff,
    s.dv__rec_source as record_source,
    s.dv__load_dtm as load_dtm
FROM
            staging_dvdrentals.store_{{ts_nodash}} s
INNER JOIN  staging_dvdrentals.staff_{{ts_nodash}} f ON s.manager_staff_id = f.staff_id
WHERE
    NOT EXISTS (
        SELECT 
                lss.hkey_store_staff
        FROM    dv_raw.link_store_staff lss
        WHERE 
                lss.hkey_store = s.dv__bk
        AND     lss.hkey_staff = f.dv__bk
    )
