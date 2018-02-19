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
AND COALESCE(sm.name, '') != COALESCE(sat.name, '')
AND COALESCE(sm.shipbase, '') != COALESCE(sat.shipbase, '')
AND COALESCE(sm.shiprate, '') != COALESCE(sat.shiprate, '')
