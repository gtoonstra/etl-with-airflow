INSERT INTO TABLE dv_raw.link_staff_store
SELECT DISTINCT
      Md5(CONCAT()) as hkey_staff_store
    , b.hkey_staff as hkey_staff
, c.hkey_store as hkey_store
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
FROM
    staging_dvdrentals.staff_{{ts_nodash}} a
  INNER JOIN dv_raw.hub_staff b ON b.staff_id = a.staff_id
  INNER JOIN dv_raw.hub_store c ON c.store_id = a.store_id
WHERE
    NOT EXISTS (
        SELECT 
                link.hkey_staff_store
        FROM    dv_raw.link_staff_store link
        WHERE 
                    link.hkey_staff = b.hkey_staff
AND     link.hkey_store = c.hkey_store

    )
