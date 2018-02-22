DROP TABLE dv_star.dim_salesterritory;

CREATE TABLE dv_star.dim_salesterritory AS
SELECT
          hub.hkey_salesterritory
        , hub.name
        , sat.territoryid
        , sat.territory_group
        , sat.salesytd
        , sat.saleslastyear
        , sat.costytd
        , sat.costlastyear
FROM
            dv_raw.sat_salesterritory sat
INNER JOIN  dv_raw.hub_salesterritory hub ON hub.hkey_salesterritory = sat.hkey_salesterritory
WHERE
        load_end_dtm IS NULL
