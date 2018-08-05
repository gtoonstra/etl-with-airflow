INSERT INTO TABLE dv_raw.hub_customer
SELECT DISTINCT
      a.dv__bk as hkey_customer
    , a.dv__rec_source as rec_source
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss.SSSXXX")) as load_dtm
    , a.email
FROM
    staging_dvdrentals.customer_{{ts_nodash}} a
WHERE
    (a.dv__status = 'NEW' OR a.dv__status = 'UPDATED')
AND
    NOT EXISTS (
        SELECT 
                hub.hkey_customer
        FROM 
                dv_raw.hub_customer hub
        WHERE
                hub.email = a.email
    )
