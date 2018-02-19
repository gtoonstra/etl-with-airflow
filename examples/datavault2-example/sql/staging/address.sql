SELECT
      a.addressid
    , a.addressline1
    , a.addressline2
    , a.city
    , a.stateprovinceid
    , a.postalcode
    , a.spatiallocation
    , CONCAT(
          LTRIM(RTRIM(COALESCE(CAST(a.postalcode as varchar), ''))), ';'
        , LTRIM(RTRIM(COALESCE(CAST(a.addressline1 as varchar), ''))), ';'
        , LTRIM(RTRIM(COALESCE(CAST(a.addressline2 as varchar), '')))
      ) as hkey_address
    , CONCAT(
          LTRIM(RTRIM(COALESCE(CAST(sp.stateprovincecode as varchar), ''))), ';'
        , LTRIM(RTRIM(COALESCE(CAST(sp.countryregioncode as varchar), '')))
      ) as hkey_stateprovince
    , CONCAT(
          LTRIM(RTRIM(COALESCE(CAST(a.postalcode as varchar), ''))), ';'
        , LTRIM(RTRIM(COALESCE(CAST(a.addressline1 as varchar), ''))), ';'
        , LTRIM(RTRIM(COALESCE(CAST(a.addressline2 as varchar), ''))), ';'
        , LTRIM(RTRIM(COALESCE(CAST(sp.stateprovincecode as varchar), ''))), ';'
        , LTRIM(RTRIM(COALESCE(CAST(sp.countryregioncode as varchar), '')))
      ) as hkey_address_stateprovince
FROM
           person.address a
INNER JOIN person.stateprovince sp ON a.stateprovinceid = sp.stateprovinceid
