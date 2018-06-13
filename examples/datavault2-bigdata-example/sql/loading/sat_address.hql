INSERT INTO TABLE dv_raw.sat_address
SELECT DISTINCT
      a.dv__bk as hkey_address
    , a.dv__load_dtm as load_dtm
    , a.dv__rec_source as record_source
    , a.address2
    , ci.city
    , co.country
    , a.district
    , a.phone
    , a.last_update
FROM
                staging_dvdrentals.address_{{ts_nodash}} a
INNER JOIN      staging_dvdrentals.city_{{ts_nodash}} ci ON a.city_id = ci.city_id
INNER JOIN      staging_dvdrentals.country_{{ts_nodash}} co ON ci.country_id = co.country_id
LEFT OUTER JOIN dv_raw.sat_address sat ON
                sat.hkey_address = a.dv__bk
         AND    sat.load_dtm = a.dv__load_dtm
WHERE
    sat.hkey_address IS NULL
