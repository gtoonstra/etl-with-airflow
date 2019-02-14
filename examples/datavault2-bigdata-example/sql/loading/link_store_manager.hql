INSERT INTO TABLE dv_raw.link_store_manager
SELECT DISTINCT
      Md5(CONCAT()) as hkey_store_manager
    , b.hkey_store as hkey_store
, c.hkey_staff as hkey_staff
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
FROM
    staging_dvdrentals.store_{{ts_nodash}} a
  INNER JOIN dv_raw.hub_store b ON b.store_id = a.store_id
  INNER JOIN dv_raw.hub_staff c ON c.staff_id = a.staff_id
WHERE
    NOT EXISTS (
        SELECT 
                link.hkey_store_manager
        FROM    dv_raw.link_store_manager link
        WHERE 
                    link.hkey_store = b.hkey_store
AND     link.hkey_staff = c.hkey_staff

    )
