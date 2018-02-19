INSERT INTO TABLE dv_raw.ref_countryregion
SELECT DISTINCT
      cr.countryregioncode
    , cr.load_dtm
    , NULL
    , cr.record_source
    , cr.name
FROM
                advworks_staging.countryregion_{{ts_nodash}} cr
LEFT OUTER JOIN dv_raw.ref_countryregion ref ON (
                ref.countryregioncode = cr.countryregioncode
            AND ref.load_end_dtm IS NULL)
WHERE
    COALESCE(cr.name, '') != COALESCE(ref.name, '')
