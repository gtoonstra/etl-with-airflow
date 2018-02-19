INSERT INTO TABLE dv_raw.sat_salesterritory
SELECT DISTINCT
      st.hkey_salesterritory
    , st.load_dtm
    , NULL
    , st.record_source
    , st.territoryid
    , st.territory_group
    , st.salesytd
    , st.saleslastyear
    , st.costytd
    , st.costlastyear
FROM
                advworks_staging.salesterritory_{{ts_nodash}} st
LEFT OUTER JOIN dv_raw.sat_salesterritory sat ON (
                sat.hkey_salesterritory = st.hkey_salesterritory
            AND sat.load_end_dtm IS NULL)
WHERE
    COALESCE(st.territoryid, '') != COALESCE(sat.territoryid, '')
AND COALESCE(st.territory_group, '') != COALESCE(sat.territory_group, '')
AND COALESCE(st.salesytd, '') != COALESCE(sat.salesytd, '')
AND COALESCE(st.saleslastyear, '') != COALESCE(sat.saleslastyear, '')
AND COALESCE(st.costytd, '') != COALESCE(sat.costytd, '')
AND COALESCE(st.costlastyear, '') != COALESCE(sat.costlastyear, '')
