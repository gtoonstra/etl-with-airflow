INSERT INTO TABLE dv_raw.link_staff_store
SELECT DISTINCT
    ss.dv__bk as hkey_staff_store,
    ss.staff_bk as hkey_staff,
    ss.store_bk as hkey_store,
    ss.dv__rec_source as record_source,
    from_unixtime(unix_timestamp(ss.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
FROM
    staging_dvdrentals.staff_store_{{ts_nodash}} ss
WHERE
    NOT EXISTS (
        SELECT 
                lss.hkey_staff_store
        FROM    dv_raw.link_staff_store lss
        WHERE 
                lss.hkey_staff = ss.staff_bk
        AND     lss.hkey_store = ss.store_bk
    )
