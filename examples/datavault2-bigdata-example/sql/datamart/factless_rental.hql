DROP TABLE dv_star.factless_rental;

CREATE TABLE dv_star.factless_rental AS
SELECT
              sat.rental_date
            , sat.return_date
            , dc.hkey_dim_customer
            , df.hkey_dim_film
            , ds.hkey_dim_store
FROM
            dv_raw.sat_rental sat
INNER JOIN  dv_raw.link_rental_customer lrc ON sat.hkey_rental = lrc.hkey_rental
INNER JOIN  dv_raw.dim_customer dc ON lrc.hkey_customer = dc.hkey_customer
INNER JOIN  dv_raw.link_rental_inventory lri ON sat.hkey_rental = lri.hkey_rental
INNER JOIN  dv_raw.link_inventory_film lif ON lri.hkey_inventory = lif.hkey_inventory
INNER JOIN  dv_raw.link_inventory_store lis ON lri.hkey_inventory = lis.hkey_inventory
INNER JOIN  dv_raw.dim_film df ON lif.hkey_film = df.hkey_film
INNER JOIN  dv_raw.dim_store ds ON lis.hkey_store = ds.hkey_store
