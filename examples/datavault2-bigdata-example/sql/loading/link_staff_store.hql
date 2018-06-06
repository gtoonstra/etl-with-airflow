INSERT INTO TABLE dv_raw.link_staff_store
SELECT DISTINCT
    upper(md5(concat(ss.hkey_staff, ss.hkey_store))) as hkey_staff_store,
    ss.hkey_staff,
    ss.hkey_store,
    ss.record_source,
    ss.load_dtm
FROM
    staging_dvdrentals.link_staff_store_{{ts_nodash}} ss
WHERE
    NOT EXISTS (
        SELECT 
                lss.hkey_staff_address
        FROM    dv_raw.link_staff_store lss
        WHERE 
                lss.hkey_staff = ca.hkey_staff
        AND     lss.hkey_store = ca.hkey_store
    )
