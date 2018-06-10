INSERT INTO TABLE dv_raw.hkey_store_staff
SELECT DISTINCT
    ss.???? as hkey_store_staff,
    ss.dv__rec_source as record_source,
    ss.dv__load_dtm as load_dtm,
    ss.dv__bk as hkey_store,
    ss.???? as hkey_staff
FROM
    staging_dvdrentals.store_{{ts_nodash}} ss
WHERE
    NOT EXISTS (
        SELECT 
                lss.hkey_store_staff
        FROM    dv_raw.hkey_store_staff lss
        WHERE 
                lss.hkey_store = ss.dv__bk
        AND     lss.hkey_staff = ss.????
    )
