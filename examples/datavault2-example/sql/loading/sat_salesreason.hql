INSERT INTO TABLE dv_raw.sat_salesreason
SELECT DISTINCT
      sr.hkey_salesreason
    , sr.load_dtm
    , NULL
    , sr.record_source
    , sr.name
    , sr.reasontype
FROM
                advworks_staging.salesreason_{{ts_nodash}} sr
LEFT OUTER JOIN dv_raw.sat_salesreason sat ON (
                sat.hkey_salesreason = sr.hkey_salesreason
            AND sat.load_end_dtm IS NULL)
WHERE
   COALESCE(sr.name, '') != COALESCE(sat.name, '')
OR COALESCE(sr.reasontype, '') != COALESCE(sat.reasontype, '')
