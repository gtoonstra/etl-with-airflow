SELECT
      sm.shipmethodid
    , sm.name
    , sm.shipbase
    , sm.shiprate
    , LTRIM(RTRIM(COALESCE(CAST(sm.name as varchar), ''))) as hkey_shipmethod
FROM
    purchasing.shipmethod sm
