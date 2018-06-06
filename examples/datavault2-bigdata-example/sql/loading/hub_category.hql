INSERT INTO TABLE dv_raw.hub_category
SELECT DISTINCT
      a.dv__bk as hkey_category
    , a.dv__rec_source as rec_source
    , a.dv__load_dtm as load_dtm
    , a.name
FROM
    staging_dvdrentals.category_{{ts_nodash}} a
WHERE
    (a.dv__status = 'NEW' OR a.dv__status = 'UPDATED')
AND
    NOT EXISTS (
        SELECT 
                hub.hkey_category
        FROM 
                dv_raw.hub_category hub
        WHERE
                hub.name = a.name
    )
