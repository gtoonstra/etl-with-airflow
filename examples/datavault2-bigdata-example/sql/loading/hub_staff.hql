INSERT INTO TABLE dv_raw.hub_staff
SELECT DISTINCT
      a.dv__bk as hkey_staff
    , a.dv__rec_source as rec_source
    , a.dv__load_dtm as load_dtm
    , a.first_name
    , a.last_name
FROM
    staging_dvdrentals.staff_{{ts_nodash}} a
WHERE
    (a.dv__status = 'NEW' OR a.dv__status = 'UPDATED')
AND
    NOT EXISTS (
        SELECT 
                hub.hkey_staff
        FROM 
                dv_raw.hub_staff hub
        WHERE
                hub.first_name = a.first_name
        AND     hub.last_name  = a.last_name
    )
