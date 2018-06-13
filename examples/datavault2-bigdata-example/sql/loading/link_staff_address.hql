INSERT INTO TABLE dv_raw.link_staff_address
SELECT DISTINCT
    sa.staff_address_bk as hkey_staff_address,
    sa.dv__bk as hkey_staff,
    sa.address_bk as hkey_address,    
    sa.dv__rec_source as record_source,
    sa.dv__load_dtm as load_dtm
FROM
    staging_dvdrentals.staff_{{ts_nodash}} sa
WHERE
    NOT EXISTS (
        SELECT 
                lsa.hkey_staff_address
        FROM    dv_raw.link_staff_address lsa
        WHERE 
                lsa.hkey_staff = sa.dv__bk
        AND     lsa.hkey_address = sa.address_bk
    )
