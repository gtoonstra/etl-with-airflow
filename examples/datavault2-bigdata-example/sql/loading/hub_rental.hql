INSERT INTO TABLE dv_raw.hub_rental
SELECT DISTINCT
      Md5(CONCAT(LTRIM(RTRIM(COALESCE(CAST(a.rental_id as string), ''))))) as hkey_rental
    , 'dvdrentals' as rec_src
    , from_unixtime(unix_timestamp("{{ts_nodash}}", "yyyyMMdd'T'HHmmss")) as load_dtm
      
    , a.rental_id
FROM
    staging_dvdrentals.rental_{{ts_nodash}} a
WHERE
    NOT EXISTS (
        SELECT 
                hub.hkey_rental
        FROM 
                dv_raw.hub_rental hub
        WHERE
                    hub.rental_id = a.rental_id

    )
