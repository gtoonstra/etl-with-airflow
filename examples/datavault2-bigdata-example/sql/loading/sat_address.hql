INSERT INTO TABLE dv_raw.sat_address
SELECT DISTINCT
      a.dv__bk as hkey_address
    , a.dv__load_dtm as load_dtm
    , a.dv__rec_source as record_source
    , address2
    , city
    , country
    , district
    , phone
    , last_update
FROM
                staging_dvdrentals.address_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_address sat ON
                sat.hkey_address = a.dv__bk
         AND    sat.load_dtm = a.dv__load_dtm
WHERE
    sat.hkey_address IS NULL
