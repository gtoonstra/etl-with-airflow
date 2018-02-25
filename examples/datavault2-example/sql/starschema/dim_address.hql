DROP TABLE dv_star.dim_address;

CREATE TABLE dv_star.dim_address AS
SELECT
        CONCAT(huba.hkey_address, ':', sata.load_dtm) as hkey_dim_address
        , huba.hkey_address
        , sata.load_dtm
        , sata.load_end_dtm
        , huba.postalcode
        , huba.addressline1
        , huba.addressline2
        , sata.city
        , sata.spatiallocation
        , hubsp.stateprovincecode
        , hubsp.countryregioncode
        , cr.name as countryregionname
        , satsp.isonlystateprovinceflag
        , satsp.name
FROM
            dv_raw.sat_address sata
INNER JOIN  dv_raw.hub_address huba ON huba.hkey_address = sata.hkey_address
INNER JOIN  dv_raw.link_address_stateprovince link ON link.hkey_address = huba.hkey_address
INNER JOIN  dv_raw.hub_stateprovince hubsp ON hubsp.hkey_stateprovince = link.hkey_stateprovince
INNER JOIN  dv_raw.sat_stateprovince satsp ON hubsp.hkey_stateprovince = satsp.hkey_stateprovince
INNER JOIN  dv_raw.ref_countryregion cr ON satsp.countryregioncode = cr.countryregioncode
WHERE
            satsp.load_end_dtm IS NULL
