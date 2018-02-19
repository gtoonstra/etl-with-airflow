SELECT
      territoryid
    , name
    , countryregioncode
    , "group" as territory_group
    , salesytd
    , saleslastyear
    , costytd
    , costlastyear
    , LTRIM(RTRIM(COALESCE(st.name, ''))) as hkey_salesterritory
FROM
    sales.salesterritory st
