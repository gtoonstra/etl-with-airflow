INSERT INTO TABLE dv_raw.hub_salesterritory
SELECT DISTINCT
    st.hkey_salesterritory,
    st.record_source,
    st.load_dtm,
    st.name
FROM
    advworks_staging.salesterritory_{{ts_nodash}} st
WHERE
    st.name NOT IN (
        SELECT hub.name FROM dv_raw.hub_salesterritory hub
    )
