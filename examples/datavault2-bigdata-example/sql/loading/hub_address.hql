INSERT INTO TABLE dv_raw.hub_address
SELECT DISTINCT
      a.dv__bk as hkey_address
    , a.dv__rec_source as rec_source
    , a.dv__load_dtm as load_dtm
    , address         STRING
    , postal_code     STRING
FROM
    staging_dvdrentals.address_{{ts_nodash}} a
WHERE
    (a.dv__status = 'NEW' OR a.dv__status = 'UPDATED')
AND
    NOT EXISTS (
        SELECT 
                hub.hkey_address
        FROM 
                dv_raw.hub_address hub
        WHERE
                hub.address = a.address
        AND     hub.postal_code = a.postal_code
    )
