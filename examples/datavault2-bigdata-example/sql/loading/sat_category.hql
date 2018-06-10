INSERT INTO TABLE dv_raw.sat_category
SELECT DISTINCT
      a.dv__bk as hkey_category
    , a.dv__load_dtm as load_dtm
    , a.dv__rec_source as record_source
    , a.last_update
FROM
                staging_dvdrentals.category_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_category sat ON
                sat.hkey_category = a.dv__bk
         AND    sat.load_dtm = a.dv__load_dtm
WHERE
    sat.hkey_category IS NULL
