INSERT INTO TABLE dv_raw.link_customer_store
SELECT DISTINCT
      Md5(CONCAT()) as hkey_customer_store
    , b.hkey_customer as hkey_customer
, c.hkey_store as hkey_store
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
FROM
    staging_dvdrentals.customer_{{ts_nodash}} a
  INNER JOIN dv_raw.hub_customer b ON b.customer_id = a.customer_id
  INNER JOIN dv_raw.hub_store c ON c.store_id = a.store_id
WHERE
    NOT EXISTS (
        SELECT 
                link.hkey_customer_store
        FROM    dv_raw.link_customer_store link
        WHERE 
                    link.hkey_customer = b.hkey_customer
AND     link.hkey_store = c.hkey_store

    )
