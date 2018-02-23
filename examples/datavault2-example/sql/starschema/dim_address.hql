DROP TABLE dv_star.dim_address;

CREATE TABLE dv_star.dim_address AS
SELECT
          huba.hkey_address
        , huba.load_dtm
        , huba.load_end_dtm
        , huba.postalcode,
        , huba.addressline1,
        , huba.addressline2
        , sat.city
        , sat.spatiallocation
        , hubsp.stateprovincecode
        , hubsp.countryregioncode
        , satsp.isonlystateprovinceflag
        , satsp.name
FROM
            dv_raw.sat_address sat
INNER JOIN  dv_raw.hub_address huba ON huba.hkey_address = sat.hkey_address
INNER JOIN  dv_raw.link_address_stateprovince link ON link.hkey_address = huba.hkey_address
INNER JOIN  dv_raw.hub_stateprovince hubsp ON hubsp.hkey_stateprovince = link.hkey_stateprovince
INNER JOIN  dv_raw.sat_stateprovince satsp ON hubsp.hkey_stateprovince = satsp.hkey_stateprovince
