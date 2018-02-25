INSERT INTO TABLE dv_raw.sat_address
SELECT DISTINCT
      a.hkey_address
    , a.load_dtm
    , NULL
    , a.record_source
    , a.addressid
    , a.city
    , a.spatiallocation
FROM
                advworks_staging.address_{{ts_nodash}} a
LEFT OUTER JOIN dv_raw.sat_address sat ON (
                sat.hkey_address = a.hkey_address
            AND sat.load_end_dtm IS NULL)
WHERE
   COALESCE(a.addressid, '') != COALESCE(sat.addressid, '')
OR COALESCE(a.city, '') != COALESCE(sat.city, '')
OR COALESCE(a.spatiallocation, '') != COALESCE(sat.spatiallocation, '')
