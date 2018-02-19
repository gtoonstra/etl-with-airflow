INSERT INTO TABLE dv_raw.link_address_stateprovince
SELECT DISTINCT
    a.hkey_address_stateprovince,
    a.hkey_stateprovince,
    a.hkey_address,
    a.record_source,
    a.load_dtm
FROM
           advworks_staging.address_{{ts_nodash}} a
WHERE
    NOT EXISTS (
        SELECT 
                l.hkey_address_stateprovince
        FROM    dv_raw.link_address_stateprovince l
        WHERE 
                l.hkey_stateprovince = a.hkey_stateprovince
        AND     l.hkey_address = a.hkey_address
    )
