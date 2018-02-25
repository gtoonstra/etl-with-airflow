INSERT INTO TABLE dv_raw.sat_shipmethod
SELECT DISTINCT
      sm.hkey_shipmethod
    , sm.load_dtm
    , NULL
    , sm.record_source
    , sm.shipmethodid
    , sm.name
    , sm.shipbase
    , sm.shiprate
FROM
                advworks_staging.shipmethod_{{ts_nodash}} sm
LEFT OUTER JOIN dv_raw.sat_shipmethod sat ON (
                sat.hkey_shipmethod = sm.hkey_shipmethod
            AND sat.load_end_dtm IS NULL)
WHERE
   COALESCE(sm.shipmethodid, '') != COALESCE(sat.shipmethodid, '')
OR COALESCE(sm.name, '') != COALESCE(sat.name, '')
OR COALESCE(sm.shipbase, '') != COALESCE(sat.shipbase, '')
OR COALESCE(sm.shiprate, '') != COALESCE(sat.shiprate, '')
