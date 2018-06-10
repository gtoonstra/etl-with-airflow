INSERT INTO TABLE dv_raw.sat_staff
SELECT DISTINCT
      a.dv__bk as hkey_staff
    , a.dv__load_dtm as load_dtm
    , a.dv__rec_source as record_source
    , a.active
    , a.email
    , a.last_update
FROM
                staging_dvdrentals.staff_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_staff sat ON
                sat.hkey_staff = a.dv__bk
         AND    sat.load_dtm = a.dv__load_dtm
WHERE
    sat.hkey_staff IS NULL
