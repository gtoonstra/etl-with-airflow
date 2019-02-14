INSERT INTO TABLE dv_raw.hub_customer
SELECT DISTINCT
      Md5(CONCAT(LTRIM(RTRIM(COALESCE(CAST(a.email as string), ''))))) as hkey_customer
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
      , a.customer_id
    , a.email
FROM
    staging_dvdrentals.customer_{{ts_nodash}} a
WHERE
    NOT EXISTS (
        SELECT 
                hub.hkey_customer
        FROM 
                dv_raw.hub_customer hub
        WHERE
                    hub.email = a.email

    )
