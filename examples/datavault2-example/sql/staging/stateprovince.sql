SELECT
      sp.stateprovinceid
    , sp.stateprovincecode
    , sp.countryregioncode
    , sp.isonlystateprovinceflag
    , sp.name
    , sp.territoryid
    , CONCAT(
          LTRIM(RTRIM(COALESCE(CAST(sp.stateprovincecode as varchar), ''))), ';'
        , LTRIM(RTRIM(COALESCE(CAST(sp.countryregioncode as varchar), '')))
      ) as hkey_stateprovince
    , LTRIM(RTRIM(COALESCE(CAST(st.name as varchar), ''))) as hkey_salesterritory
    , LTRIM(RTRIM(COALESCE(CAST(cr.countryregioncode as varchar), ''))) as hkey_countryregion
FROM
           person.stateprovince sp
INNER JOIN sales.salesterritory st ON sp.territoryid = st.territoryid
INNER JOIN person.countryregion cr ON sp.countryregioncode = cr.countryregioncode
