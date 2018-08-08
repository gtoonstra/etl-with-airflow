INSERT INTO TABLE dv_raw.hub_rental
SELECT DISTINCT
      a.dv__bk as hkey_rental
    , a.dv__rec_source as rec_source
    , from_unixtime(unix_timestamp(a.dv__load_dtm, "yyyy-MM-dd'T'HH:mm:ss")) as load_dtm
    , a.rental_id
FROM
    staging_dvdrentals.rental_{{ts_nodash}} a
WHERE
    (a.dv__status = 'NEW' OR a.dv__status = 'UPDATED')
AND
    NOT EXISTS (
        SELECT 
                hub.hkey_rental
        FROM 
                dv_raw.hub_rental hub
        WHERE
                hub.rental_id = a.rental_id
    )
