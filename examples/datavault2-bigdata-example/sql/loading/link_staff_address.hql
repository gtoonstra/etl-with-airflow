INSERT INTO TABLE dv_raw.link_staff_address
SELECT DISTINCT
    upper(md5(concat(sa.hkey_staff, sa.hkey_address))) as hkey_staff_address,
    sa.record_source,
    sa.load_dtm,
    sa.hkey_staff,
    sa.hkey_address
FROM
    staging_dvdrentals.staff_address_{{ts_nodash}} sa
WHERE
    NOT EXISTS (
        SELECT 
                lsa.hkey_staff_address
        FROM    dv_raw.link_staff_address lsa
        WHERE 
                lsa.hkey_staff = sa.hkey_staff
        AND     lsa.hkey_address = sa.hkey_address
    )
