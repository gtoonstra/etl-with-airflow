INSERT INTO TABLE dv_raw.hkey_store_staff
SELECT DISTINCT
    upper(md5(concat(ss.hkey_store, ss.hkey_staff))) as hkey_store_staff,
    ss.record_source,
    ss.load_dtm,
    ss.hkey_store,
    ss.hkey_staff
FROM
    staging_dvdrentals.store_staff_{{ts_nodash}} ss
WHERE
    NOT EXISTS (
        SELECT 
                lss.hkey_store_staff
        FROM    dv_raw.hkey_store_staff lss
        WHERE 
                lss.hkey_store = ss.hkey_store
        AND     lss.hkey_staff = ss.hkey_staff
    )
